# KaliBspwm - Pacman/Arcade Theme Dotfiles

<p align="center">
  <img src="https://github.com/Jhontabo/KaliBspwm/blob/main/Design%20preview%20(Useless)/Picture4.PNG" alt="KaliBspwm Preview">
</p>

A highly customized BSPWM configuration with a Pacman/Arcade theme, inspired by Kali Linux aesthetics. This repository contains my personal dotfiles including window manager (BSPWM), terminal (Kitty), shell (ZSH with Oh My Zsh), launcher (Rofi), and more.

## Features

- **Window Manager**: BSPWM with custom keybindings (sxhkd)
- **Terminal**: Kitty with custom theming
- **Shell**: ZSH with Oh My Zsh, Powerlevel10k theme
- **Application Launcher**: Rofi with arcade-style configuration
- **File Browser**: lsd (Rust-based ls replacement)
- **Custom Scripts**: Useful scripts for system management
- **Wallpapers**: Curated collection of wallpapers
- **Fonts**: Custom fonts for terminal and UI

## Prerequisites

Before installing, make sure your system is up to date:

```bash
sudo apt update && sudo apt upgrade -y
```

### Required Dependencies

This configuration is designed for **Debian/Ubuntu-based distributions**. The install script will attempt to install most dependencies, but you may need to install the following manually:

- BSPWM
- SXHKD
- Kitty
- ZSH
- Oh My Zsh
- Rofi
- polybar (optional)
- picom (compton)
- Nitrogen (wallpaper manager)
- fonts (nerd-fonts recommended)

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/Jhontabo/KaliBspwm.git

# Navigate to the directory
cd KaliBspwm

# Make the install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

### Manual Installation

If you prefer to install manually:

```bash
# Create backup of your existing dotfiles (optional but recommended)
mkdir -p ~/.config/bkp
cp -r ~/.config/bspwm ~/.config/bkp/ 2>/dev/null
cp -r ~/.config/sxhkd ~/.config/bkp/ 2>/dev/null
cp ~/.zshrc ~/.config/bkp/ 2>/dev/null

# Copy configuration files
cp -r Config/* ~/.config/
cp .zshrc ~/
cp .p10k.zsh ~/

# Copy additional files
cp -r kitty ~/.config/
cp -r rofi ~/.config/
cp -r scripts ~/
cp -r Wallpaper ~/Pictures/
```

## Repository Structure

```
KaliBspwm/
├── Config/              # Configuration files for bspwm, sxhkd, etc.
├── Components/         # Additional components and utilities
├── fonts/              # Custom fonts
├── kitty/              # Kitty terminal configuration
├── rofi/               # Rofi launcher configuration
├── scripts/            # Custom shell scripts
├── Wallpaper/          # Wallpaper collection
├── install.sh          # Installation script
├── sync.sh             # Sync script for updating
├── .zshrc              # ZSH configuration
└── .p10k.zsh           # Powerlevel10k configuration
```

## Post-Installation

After installation:

1. Log out and select BSPWM as your window manager (or restart X)
2. Open a terminal and verify everything is working
3. Customize colors, keybindings, and themes to your preference

## Customization

### Keybindings

Edit `~/.config/sxhkd/sxhkdrc` to customize keyboard shortcuts.

### Theme Colors

Colors are defined in:
- `~/.config/bspwm/bspwmrc`
- `~/.config/rofi/config.rasi`
- `~/.config/kitty/kitty.conf`

### Terminal Font

Install Nerd Fonts for best experience:
```bash
# Or use the fonts included in this repository
```

## Troubleshooting

### Black screen after login
- Check if BSPWM is installed: `which bspwm`
- Check X11 logs: `cat ~/.local/share/bspwm/logs`
- Try starting sxhkd manually: `sxhkd &`

### Terminal not displaying correctly
- Ensure Kitty is installed: `kitty --version`
- Check font configuration in `~/.config/kitty/kitty.conf`

### Rofi not working
- Verify rofi installation: `rofi --version`
- Check configuration in `~/.config/rofi/`

## Credits

- Original concept based on [ZLCubewm](https://github.com/ZLCubewm)
- Theme inspired by Kali Linux
- Arcade/Pacman aesthetic customization

## Screenshots

More screenshots available in `Design preview (Useless)/` folder.

## License

Personal dotfiles - Feel free to use and modify for your own setup.

---

If you find these dotfiles useful, please consider starring the repository!
