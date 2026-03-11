#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "[!] Do not run this script as root. Use your normal user with sudo enabled."
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-ubuntuBspwm-$(date +%Y%m%d-%H%M%S)"

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }
die() { printf '[x] %s\n' "$*" >&2; exit 1; }

package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

package_available() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_packages() {
  local pkgs=()
  local missing=()
  local pkg

  for pkg in "$@"; do
    if ! package_available "$pkg"; then
      missing+=("$pkg")
      continue
    fi
    if ! package_installed "$pkg"; then
      pkgs+=("$pkg")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    die "Required packages not available in APT: ${missing[*]}"
  fi

  if (( ${#pkgs[@]} > 0 )); then
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${pkgs[@]}"
  fi
}

install_optional_packages() {
  local pkgs=()
  local pkg

  for pkg in "$@"; do
    if ! package_available "$pkg"; then
      warn "Optional package not available, skipping: $pkg"
      continue
    fi
    if ! package_installed "$pkg"; then
      pkgs+=("$pkg")
    fi
  done

  if (( ${#pkgs[@]} > 0 )); then
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${pkgs[@]}"
  fi
}

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$target" "$BACKUP_DIR/"
  fi
}

copy_config_dir() {
  local src="$1"
  local dst="$2"

  if [[ ! -d "$src" ]]; then
    warn "Source directory does not exist: $src"
    return
  fi

  backup_path "$dst"
  rm -rf "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
}

copy_file_if_exists() {
  local src="$1"
  local dst="$2"

  if [[ -f "$src" ]]; then
    backup_path "$dst"
    cp -f "$src" "$dst"
  else
    warn "File does not exist: $src"
  fi
}

log "Updating APT indices..."
sudo apt update

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" == "ubuntu" ]] && ! grep -RhsE '^[^#].*ubuntu.com/ubuntu.*[[:space:]]universe([[:space:]]|$)' /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null 2>&1; then
    log "Enabling universe repository (Ubuntu)..."
    install_packages software-properties-common
    sudo add-apt-repository -y universe
    sudo apt update
  fi
fi

log "Installing base packages and BSPWM environment..."
polkit_pkg=""
if package_available polkitd; then
  polkit_pkg="polkitd"
elif package_available policykit-1; then
  polkit_pkg="policykit-1"
else
  die "Neither polkitd nor policykit-1 is available in APT repositories."
fi

install_packages \
  apt-transport-https ca-certificates curl wget git unzip build-essential \
  xorg xinit dbus-x11 "$polkit_pkg" \
  bspwm sxhkd picom polybar rofi feh xclip scrot wmname acpi xdotool \
  kitty thunar network-manager net-tools \
  alsa-utils pulseaudio-utils \
  zsh zsh-syntax-highlighting zsh-autosuggestions \
  xdg-utils imagemagick plocate

install_optional_packages \
  flameshot pipewire wireplumber cmatrix ranger neofetch scrub \
  papirus-icon-theme \
  fonts-font-awesome \
  libnotify-bin

if ! package_installed lightdm && ! package_installed gdm3 && ! package_installed sddm; then
  log "No display manager detected, installing LightDM..."
  install_packages lightdm lightdm-gtk-greeter
fi

install_packages i3lock

if systemctl list-unit-files 2>/dev/null | grep -q '^NetworkManager\\.service'; then
  sudo systemctl enable --now NetworkManager >/dev/null 2>&1 || true
fi

if ! systemctl list-unit-files 2>/dev/null | grep -q '^display-manager\.service'; then
  warn "No active display manager detected. Make sure to select BSPWM in your current display manager or login screen."
fi

log "Copying configurations to ~/.config ..."
mkdir -p "$HOME/.config"
copy_config_dir "$SCRIPT_DIR/Config/bspwm" "$HOME/.config/bspwm"
copy_config_dir "$SCRIPT_DIR/Config/sxhkd" "$HOME/.config/sxhkd"
copy_config_dir "$SCRIPT_DIR/Config/picom" "$HOME/.config/picom"
copy_config_dir "$SCRIPT_DIR/Config/polybar" "$HOME/.config/polybar"
copy_config_dir "$SCRIPT_DIR/Config/bin" "$HOME/.config/bin"
copy_config_dir "$SCRIPT_DIR/Config/kitty" "$HOME/.config/kitty"
copy_config_dir "$SCRIPT_DIR/rofi" "$HOME/.config/rofi"

log "Copying wallpapers and utilities..."
mkdir -p "$HOME/Wallpaper" "$HOME/ScreenShots"
if [[ -d "$SCRIPT_DIR/Wallpaper" ]]; then
  cp -af "$SCRIPT_DIR/Wallpaper/." "$HOME/Wallpaper/"
fi

sudo install -m 0755 "$SCRIPT_DIR/scripts/whichSystem.py" /usr/local/bin/whichSystem.py
sudo install -m 0755 "$SCRIPT_DIR/scripts/screenshot" /usr/local/bin/screenshot

log "Installing fonts for the user..."
mkdir -p "$HOME/.local/share/fonts"
if [[ -d "$SCRIPT_DIR/fonts/HNF" ]]; then
  cp -af "$SCRIPT_DIR/fonts/HNF/." "$HOME/.local/share/fonts/"
fi
fc-cache -fv >/dev/null || true

log "Configuring ZSH and Powerlevel10k..."
if [[ ! -d "$HOME/.powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k"
fi

if [[ -f "$SCRIPT_DIR/.zshrc" ]]; then
  copy_file_if_exists "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
else
  cat > "$HOME/.zshrc" <<'ZSHRC'
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
ZSHRC
fi

if [[ -f "$SCRIPT_DIR/.p10k.zsh" ]]; then
  copy_file_if_exists "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
fi

if ! grep -q 'powerlevel10k.zsh-theme' "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'APPEND'
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
APPEND
fi

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)" "$USER" || warn "Could not change shell automatically. Run: chsh -s $(command -v zsh)"
fi

log "Setting executable permissions..."
chmod +x "$HOME/.config/bspwm/bspwmrc" \
         "$HOME/.config/bspwm/scripts/bspwm_resize" \
         "$HOME/.config/bin/ethernet_status.sh" \
         "$HOME/.config/bin/htb_status.sh" \
         "$HOME/.config/bin/htb_target.sh" \
         "$HOME/.config/polybar/launch.sh"

if command -v notify-send >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  notify-send "BSPWM" "Installation complete" || true
fi

cat <<'MSG'

Installation complete.

Recommended next steps:
1) Log out and select BSPWM in your display manager (login screen).
2) If your display manager is not listed, log out and choose BSPWM from the session selector.
3) Verify key dependencies:
   bspwm --version && sxhkd -v && polybar --version && picom --version

MSG
