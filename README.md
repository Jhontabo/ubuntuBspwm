# ubuntuBspwm

Pacman/arcade-themed BSPWM dotfiles for Ubuntu/Debian, with an automated installer and a full desktop setup (BSPWM, SXHKD, Polybar, Picom, Kitty, Rofi, Zsh + Starship, custom scripts, wallpapers, and fonts).

This setup is based on [ZLCube/KaliBspwm](https://github.com/ZLCube/KaliBspwm), adapted and extended for this repository.

## Desktop Preview

![Desktop Preview 1](./screenshots/desktop-01.png)
![Desktop Preview 2](./screenshots/desktop-02.png)
![Desktop Preview 3](./screenshots/desktop-03.png)
![Desktop Preview 4](./screenshots/desktop-04.png)

## Features

- BSPWM + SXHKD tiling setup
- Polybar and Picom preconfigured
- Picom auto-selects a VM-safe profile (`xrender`, no blur) when virtualized
- Kitty + Rofi themed configuration
- Zsh with Starship
- Included custom scripts (`screenshot`, `whichSystem.py`, `wall`, `file-manager-smart`, polybar helpers)
- Built-in wallpaper and font collection
- One-command installer for Ubuntu/Desktop and Ubuntu/Server scenarios

## Requirements

- Debian/Ubuntu-based distro
- `sudo` access
- Internet connection for package installation
- An existing display manager or willingness to launch BSPWM with `startx`

## Installation

### Quick Install (`wget` / `curl`)

```bash
bash <(wget -qO- https://raw.githubusercontent.com/Jhontabo/ubuntuBspwm/main/bootstrap.sh)
```

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jhontabo/ubuntuBspwm/main/bootstrap.sh)
```

### Standard Install (`git clone`)

```bash
git clone https://github.com/Jhontabo/ubuntuBspwm.git
cd ubuntuBspwm
chmod +x install.sh
./install.sh
```

## Uninstall

```bash
cd ubuntuBspwm
chmod +x uninstall.sh
./uninstall.sh
```

## What `install.sh` Does

- Installs required packages (BSPWM, SXHKD, Polybar, Picom, Kitty, Rofi, Zsh, etc.)
- Copies repo configs to `~/.config`
- Installs wallpapers to `~/Wallpaper`
- Installs included fonts to `~/.local/share/fonts`
- Installs helper scripts to `/usr/local/bin` and `~/.local/bin`
- Configures Zsh + Starship
- Creates backups of existing configs before replacing them

## Repository Structure

```text
ubuntuBspwm/
├── Config/          # bspwm, sxhkd, polybar, picom, kitty, and helper configs
├── .config/         # extra user config files copied by the installer (Starship)
├── fonts/           # bundled fonts
├── kitty/           # legacy kitty config mirror
├── rofi/            # rofi config and themes
├── scripts/         # utility scripts installed locally/system-wide
├── screenshots/     # desktop preview images used in README
├── Wallpaper/       # wallpaper collection
├── bootstrap.sh     # quick installer entrypoint for wget/curl
├── install.sh       # main installer
├── uninstall.sh     # uninstall helper (removes files + restores latest backup)
└── .zshrc
```

## Post-Install

1. Log out and select **BSPWM** from your current login manager, or run `startx` if you do not use one.
2. Verify core tools:
   `bspwm --version && sxhkd -v && polybar --version && picom --version`
3. If compositor issues appear, inspect:
   `tail -n 80 ~/.cache/picom.log`

## Credits

- Base repository: [ZLCube/KaliBspwm](https://github.com/ZLCube/KaliBspwm)
- Theme style inspired by Kali/arcade aesthetics
