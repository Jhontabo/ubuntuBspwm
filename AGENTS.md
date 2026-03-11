# Repository Guidelines

## Project Structure & Module Organization
This repository ships a BSPWM desktop setup for Ubuntu/Debian.
- `install.sh`, `uninstall.sh`, `bootstrap.sh`: main lifecycle scripts.
- `Config/`: desktop configuration copied into `~/.config` (`bspwm`, `sxhkd`, `polybar`, `picom`, `kitty`, `bin`).
- `rofi/`, `kitty/`: additional theme/config sources used during install.
- `scripts/`: helper executables installed to `/usr/local/bin` (for example `screenshot`, `whichSystem.py`).
- `fonts/`, `Wallpaper/`, `screenshots/`: bundled assets.

## Build, Test, and Development Commands
There is no compile step; changes are validated by running installer scripts.
- `chmod +x install.sh && ./install.sh`: install or update the local setup.
- `chmod +x uninstall.sh && ./uninstall.sh`: remove installed files and restore latest backup.
- `bash bootstrap.sh`: download and execute installer from archive flow.
- `bash -n install.sh uninstall.sh bootstrap.sh`: syntax-check shell scripts before committing.

## Coding Style & Naming Conventions
- Use Bash with strict mode (`set -euo pipefail`) for scripts.
- Prefer small reusable functions and `snake_case` names (`install_packages`, `backup_path`).
- Keep logging consistent with existing helpers (`log`, `warn`, `die`).
- Use 2-space indentation in shell blocks, matching current scripts.
- Keep file and directory names lowercase unless existing paths are already established (`Config/`, `Wallpaper/`).

## Testing Guidelines
This project currently uses manual validation instead of an automated test framework.
- Run syntax checks: `bash -n *.sh`.
- Validate install path in a fresh Ubuntu/Debian environment.
- Confirm core tools after install:
  `bspwm --version && sxhkd -v && polybar --version && picom --version`.
- For config changes, verify affected hotkeys/themes directly in a BSPWM session.

## Commit & Pull Request Guidelines
Follow the Conventional Commit style already used in history:
- `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`, `delete: ...`.
- Keep commits scoped to one concern (for example, only rofi theme fixes).

For pull requests, include:
- Short summary of user-visible changes.
- Validation steps executed (install, uninstall, syntax checks).
- Screenshots for UI/theme updates (`screenshots/`-style evidence).
- Linked issue or rationale when changing package lists or session defaults.
