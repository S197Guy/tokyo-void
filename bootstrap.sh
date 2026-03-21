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
    quickshell
    neovim
    ranger
    fish-shell
    alacritty
    starship
    tlp
    brightnessctl
    elogind
    polkit
    dbus
    mesa-dri
    git
    curl
    wget
    fuzzel\n    eza
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
    tlp
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

echo -e "${GREEN}Bootstrap complete! Please reboot or start Niri manually.${NC}"
