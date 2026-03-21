#!/usr/bin/env bash

# tokyo-void bootstrap script
set -e

# Colors
BLUE="\033[0;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}Starting tokyo-void bootstrap...${NC}"

# 1. Install Core Packages
PKGS=(
    niri
    greetd
    tuigreet
    quickshell
    neovim
    ranger
    fish-shell
    alacritty
    starship
    tlp\n    greetd
    brightnessctl
    elogind
    polkit
    dbus
    mesa-dri
    podman
    crun
    conmon
    slirp4netns
    fuse-overlayfs
    podman-compose
    rust
    go
    nodejs-lts
    git
    curl
    wget
    fuzzel
    eza
    swaybg
    swayidle
    swaylock
    pipewire
    wireplumber
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
)

echo -e "${BLUE}Installing packages...${NC}"
sudo xbps-install -Sy "${PKGS[@]}"

# 2. Enable Services
SERVICES=(
    dbus
    elogind
    polkitd
    tlp\n    greetd
)

echo -e "${BLUE}Enabling services...${NC}"
for service in "${SERVICES[@]}"; do
    if [ ! -L "/var/service/$service" ]; then
        sudo ln -s "/etc/sv/$service" /var/service/
        echo -e "${GREEN}Enabled $service${NC}"
    else
        echo -e "Service $service already enabled."
    fi
done

# 3. Symlink Configs
echo -e "${BLUE}Linking configurations...${NC}"
mkdir -p ~/.config
for dir in ~/tokyo-void/dotconfig/*; do
    target="$HOME/.config/$(basename "$dir")"
    if [ -e "$target" ]; then
        echo -e "${RED}Warning:${NC} $target already exists. Skipping."
    else
        ln -s "$dir" "$target"
        echo -e "${GREEN}Linked $(basename "$dir")${NC}"
    fi
done


# 4. Greetd Config (requires sudo)
echo -e "${BLUE}Configuring greetd...${NC}"
sudo mkdir -p /etc/greetd
sudo cp ~/tokyo-void/etc/greetd/config.toml /etc/greetd/config.toml


# 5. Podman Setup (Rootless & Namespaces)
echo -e "${BLUE}Configuring Podman for rootless usage...${NC}"
# Enable unprivileged user namespaces
sudo mkdir -p /etc/sysctl.d
echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/99-podman.conf
sudo sysctl -p /etc/sysctl.d/99-podman.conf

# Setup subuid/subgid if not present
if ! grep -q "$USER" /etc/subuid; then
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
    echo -e "${GREEN}Assigned sub-UIDs/GIDs to $USER${NC}"
fi


# 6. NPM Global Setup
echo -e "${BLUE}Configuring NPM global prefix...${NC}"
mkdir -p ~/.npm-global
npm config set prefix "~/.npm-global"


# 7. Void-specific Permissions & Groups
echo -e "${BLUE}Configuring user groups and permissions...${NC}"
# Add current user to essential groups
sudo usermod -aG video,audio,input,storage,network,wheel "$USER"

# Add the greetd user to video/input so tuigreet can render
if id "_greeter" &>/dev/null; then
    sudo usermod -aG video,input _greeter
elif id "greeter" &>/dev/null; then
    sudo usermod -aG video,input greeter
fi

# Ensure XDG_RUNTIME_DIR is handled (essential for Wayland on Void)
if ! grep -q "XDG_RUNTIME_DIR" ~/.bash_profile 2>/dev/null; then
    echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bash_profile
    echo "export XDG_SESSION_TYPE=wayland" >> ~/.bash_profile
fi
\necho -e "${GREEN}Bootstrap complete! Please reboot or start Niri manually.${NC}"
