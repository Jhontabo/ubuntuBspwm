#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "[!] Do not run this script as root. Use your normal user with sudo enabled."
  exit 1
fi

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

LATEST_BACKUP="$(ls -1dt "$HOME"/.config-backup-ubuntuBspwm-* 2>/dev/null | head -n 1 || true)"

remove_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf "$target"
    log "Removed: $target"
  fi
}

restore_from_backup_if_exists() {
  local source_name="$1"
  local destination="$2"
  local source_path="$LATEST_BACKUP/$source_name"

  if [[ -n "$LATEST_BACKUP" && -e "$source_path" ]]; then
    rm -rf "$destination"
    mkdir -p "$(dirname "$destination")"
    cp -a "$source_path" "$destination"
    log "Restored from backup: $destination"
  fi
}

log "Removing ubuntuBspwm user files..."
remove_path "$HOME/.config/nvim"
remove_path "$HOME/.config/bspwm"
remove_path "$HOME/.config/sxhkd"
remove_path "$HOME/.config/picom"
remove_path "$HOME/.config/polybar"
remove_path "$HOME/.config/bin"
remove_path "$HOME/.config/kitty"
remove_path "$HOME/.config/rofi"
remove_path "$HOME/.config/starship.toml"
remove_path "$HOME/.local/bin/wall"
remove_path "$HOME/.local/bin/file-manager-smart"
remove_path "$HOME/.local/share/nvim"
remove_path "$HOME/.local/state/nvim"
remove_path "$HOME/.cache/nvim"
remove_path "$HOME/.dmrc"
remove_path "$HOME/.xsession"
remove_path "$HOME/.xinitrc"
remove_path "$HOME/Wallpaper"
remove_path "$HOME/ScreenShots"
remove_path "$HOME/.zshrc"

log "Removing installed fonts from ~/.local/share/fonts..."
if [[ -d "$HOME/.local/share/fonts" ]]; then
  find "$HOME/.local/share/fonts" -maxdepth 1 -type f \
    \( -name '*Nerd Font*' -o -name '3270*' -o -name 'Hurmit*' -o -name 'Hack*' \) \
    -print -delete || true
  fc-cache -fv >/dev/null || true
fi

log "Removing helper binaries from /usr/local/bin..."
if command -v sudo >/dev/null 2>&1; then
  sudo rm -f /usr/local/bin/whichSystem.py /usr/local/bin/screenshot
else
  warn "sudo not found. Could not remove /usr/local/bin/whichSystem.py and /usr/local/bin/screenshot."
fi

if [[ -n "$LATEST_BACKUP" ]]; then
  log "Found backup: $LATEST_BACKUP"
  restore_from_backup_if_exists "bspwm" "$HOME/.config/bspwm"
  restore_from_backup_if_exists "sxhkd" "$HOME/.config/sxhkd"
  restore_from_backup_if_exists "picom" "$HOME/.config/picom"
  restore_from_backup_if_exists "polybar" "$HOME/.config/polybar"
  restore_from_backup_if_exists "bin" "$HOME/.config/bin"
  restore_from_backup_if_exists "kitty" "$HOME/.config/kitty"
  restore_from_backup_if_exists "rofi" "$HOME/.config/rofi"
  restore_from_backup_if_exists "nvim-config" "$HOME/.config/nvim"
  restore_from_backup_if_exists "nvim-data" "$HOME/.local/share/nvim"
  restore_from_backup_if_exists "nvim-state" "$HOME/.local/state/nvim"
  restore_from_backup_if_exists "nvim-cache" "$HOME/.cache/nvim"
  restore_from_backup_if_exists "starship.toml" "$HOME/.config/starship.toml"
  restore_from_backup_if_exists "local-bin-wall" "$HOME/.local/bin/wall"
  restore_from_backup_if_exists "local-bin-file-manager-smart" "$HOME/.local/bin/file-manager-smart"
  restore_from_backup_if_exists ".dmrc" "$HOME/.dmrc"
  restore_from_backup_if_exists ".xsession" "$HOME/.xsession"
  restore_from_backup_if_exists ".xinitrc" "$HOME/.xinitrc"
  restore_from_backup_if_exists ".zshrc" "$HOME/.zshrc"
else
  warn "No backup found (.config-backup-ubuntuBspwm-*). Nothing to restore."
fi

cat <<'MSG'

Uninstall finished.

Notes:
- Installed APT packages are NOT removed automatically.
- Zsh shell default is NOT reverted automatically.

MSG
