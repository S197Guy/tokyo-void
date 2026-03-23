#!/usr/bin/env bash

# tokyo-void bootstrap script
set -e

# Colors
BLUE="\033[0;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

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

# 1. Install Core Packages
PKGS=(niri greetd tuigreet quickshell neovim ranger fish-shell alacritty starship tlp brightnessctl elogind polkit dbus mesa-dri seatd mesa-vulkan-intel mesa-vulkan-radeon podman crun conmon slirp4netns fuse-overlayfs podman-compose rust go nodejs-lts git curl wget fuzzel eza swww swayidle swaylock pipewire wireplumber xdg-desktop-portal-gtk xdg-desktop-portal-wlr noto-fonts-ttf font-awesome-otf nerd-fonts-symbols-ttf font-jetbrains-mono-otf)

echo -e "${BLUE}Installing packages...${NC}"
sudo xbps-install -Syu || true
sudo xbps-install -yu "${PKGS[@]}" || true

# 2. Enable Services
SERVICES=(dbus elogind polkitd tlp greetd seatd)

# Create greetd runit service
if [ ! -d "/etc/sv/greetd" ]; then
    sudo mkdir -p "/etc/sv/greetd"
    sudo bash -c 'printf "#!/bin/sh\nexec 2>&1\nexport TERM=linux\nexport PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\nsv check dbus || exit 1\nsv check elogind || exit 1\nsv check seatd || exit 1\n/usr/bin/clear > /dev/tty1\nexec /usr/bin/greetd\n" > /etc/sv/greetd/run'
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

# 7. Niri Session Wrapper
echo -e "${BLUE}Creating niri-session wrapper...${NC}"
sudo bash -c 'printf "#!/bin/bash\nexport XDG_SESSION_TYPE=wayland\nexport XDG_RUNTIME_DIR=/run/user/\$(id -u)\nexport WLR_NO_HARDWARE_CURSORS=1\nexport QT_QPA_PLATFORM=wayland\nexport GDK_BACKEND=wayland\nexport PATH=\$PATH:/usr/local/bin:\$HOME/.npm-global/bin\n\n# Wait for elogind to create runtime dir\nfor i in {1..10}; do\n    [ -d \"\$XDG_RUNTIME_DIR\" ] && break\n    sleep 0.5\ndone\n\nexec niri --session\n" > /usr/local/bin/niri-session'
sudo chmod +x /usr/local/bin/niri-session

# 8. Permissions & Polkit
echo -e "${BLUE}Configuring permissions and Polkit rules...${NC}"
sudo usermod -aG video,audio,input,storage,network,wheel,greeter,"$(id -gn)",_seatd "$USER" 2>/dev/null || true
sudo usermod -aG video,input,tty,greeter,_seatd,_greetd greeter 2>/dev/null || true

# Allow wheel group to shutdown/reboot without password
sudo mkdir -p /etc/polkit-1/rules.d
sudo bash -c 'cat <<EOF > /etc/polkit-1/rules.d/10-power-management.rules
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.reboot" ||
         action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
         action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.power-off-multiple-sessions") &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF'

if ! grep -q "XDG_RUNTIME_DIR" ~/.bash_profile 2>/dev/null; then
    echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bash_profile
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.bash_profile
fi

# Update font cache
echo -e "${BLUE}Updating font cache...${NC}"
sudo fc-cache -fv

echo -e "${GREEN}Bootstrap complete! Reboot now.${NC}"
