# tokyo-void

A declarative-style configuration for Void Linux on a development laptop, featuring a **Tokyo Night** theme and the **Niri** compositor.

## 🌃 Aesthetic
- **Theme:** Tokyo Night (Storm)
- **Compositor:** Niri
- **UI Shell:** Quickshell
- **Terminal:** Alacritty / Fish / Starship
- **Editor:** Neovim
- **File Manager:** Ranger

## 🛠 Setup

### 1. Bootstrap
Run the bootstrap script to install packages and enable services:
```bash
./bootstrap.sh
```

### 2. Core Components
- **Niri:** Scrollable tiling Wayland compositor.
- **Quickshell:** Modular UI shell for status bars and widgets.
- **TLP:** Optimized power management for laptops.

## 📂 Structure
- `dotconfig/`: Source for `~/.config/`.
- `scripts/`: Maintenance and utility scripts.
- `services/`: Runit service templates.

## 📖 Reference
- [Void Linux Handbook](https://docs.voidlinux.org/)
- [Niri Documentation](https://github.com/YaLTeR/niri)
