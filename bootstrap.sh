#!/usr/bin/env bash

# tokyo-void bootstrap script
set -e

# Colors
BLUE="[0;34m"
GREEN="[0;32m"
RED="[0;31m"
NC="[0m"

# Ensure NOT run as root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}Error: Do NOT run this script with sudo.${NC}"
    echo "It will ask for sudo when needed."
    exit 1
fi

echo -e "${BLUE}Starting tokyo-void bootstrap...${NC}"

# Ensure greeter user exists
if ! id "greeter" &>/dev/null; then
    sudo useradd -M -G video,input,tty -s /sbin/nologin greeter
fi

# 1. Install Core Packages (Adding seatd and vulkan drivers)
PKGS=(niri greetd tuigreet quickshell neovim ranger fish-shell alacritty starship tlp brightnessctl elogind polkit dbus mesa-dri seatd mesa-vulkan-intel mesa-vulkan-radeon podman crun conmon slirp4netns fuse-overlayfs podman-compose rust go nodejs-lts git curl wget fuzzel eza swaybg swayidle swaylock pipewire wireplumber xdg-desktop-portal-gtk xdg-desktop-portal-wlr noto-fonts-ttf font-awesome)

echo -e "${BLUE}Installing packages...${NC}"
sudo xbps-install -Syu || true
sudo xbps-install -y "${PKGS[@]}"

# 2. Enable Services
SERVICES=(dbus elogind polkitd tlp greetd seatd)

# Create greetd runit service
if [ ! -d "/etc/sv/greetd" ]; then
    sudo mkdir -p "/etc/sv/greetd"
    sudo bash -c 'printf "#!/bin/sh
exec 2>&1
export TERM=linux
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
sv check dbus || exit 1
sv check elogind || exit 1
sv check seatd || exit 1
/usr/bin/clear > /dev/tty1
exec /usr/bin/greetd
" > /etc/sv/greetd/run'
    sudo chmod +x /etc/sv/greetd/run
fi

echo -e "${BLUE}Enabling services...${NC}"
if [ -L "/var/service/agetty-tty1" ]; then
    sudo rm /var/service/agetty-tty1
    sudo sv stop agetty-tty1 2>/dev/null || true
fi

for service in "${SERVICES[@]}"; do
    if [ ! -L "/var/service/$service" ]; then
        sudo ln -s "/etc/sv/$service" /var/service/
        echo -e "${GREEN}Enabled $service${NC}"
    fi
done

# 3. Symlink Configs
echo -e "${BLUE}Linking configurations...${NC}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ~/.config
for source_path in "$SCRIPT_DIR/dotconfig/"*; do
    name=$(basename "$source_path")
    target="$HOME/.config/$name"
    rm -rf "$target"
    ln -sf "$source_path" "$target"
done

# 4. Greetd Config
echo -e "${BLUE}Configuring greetd...${NC}"
sudo mkdir -p /etc/greetd
sudo cp "$SCRIPT_DIR/etc/greetd/config.toml" /etc/greetd/config.toml
sudo mkdir -p /var/cache/tuigreet
sudo chown greeter:greeter /var/cache/tuigreet

# 5. Podman Setup
echo -e "${BLUE}Configuring Podman...${NC}"
sudo mkdir -p /etc/sysctl.d
echo "user.max_user_namespaces=28633" | sudo tee /etc/sysctl.d/99-podman.conf
sudo sysctl -p /etc/sysctl.d/99-podman.conf
if ! grep -q "$USER" /etc/subuid; then
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
fi

# 6. NPM Global Setup
mkdir -p ~/.npm-global
npm config set prefix "~/.npm-global"

# 7. Niri Session Wrapper (Refined for seatd and no hardware cursor fallback)
echo -e "${BLUE}Creating niri-session wrapper...${NC}"
sudo bash -c 'printf "#!/bin/bash
export XDG_SESSION_TYPE=wayland
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export WLR_NO_HARDWARE_CURSORS=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export PATH=\$PATH:/usr/local/bin:\$HOME/.npm-global/bin

# Wait for elogind to create runtime dir
for i in {1..10}; do
    [ -d \"\$XDG_RUNTIME_DIR\" ] && break
    sleep 0.5
done

exec niri --session
" > /usr/local/bin/niri-session'
sudo chmod +x /usr/local/bin/niri-session

# 8. Permissions
sudo usermod -aG video,audio,input,storage,network,wheel,greeter,"$(id -gn)",_seatd "$USER" 2>/dev/null || true
sudo usermod -aG video,input,tty,greeter,_seatd,_greetd greeter 2>/dev/null || true

if ! grep -q "XDG_RUNTIME_DIR" ~/.bash_profile 2>/dev/null; then
    echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bash_profile
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.bash_profile
fi

echo -e "${GREEN}Bootstrap complete! Reboot now.${NC}"
