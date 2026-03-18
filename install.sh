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

backup_named_path() {
  local backup_name="$1"
  local target="$2"

  if [[ ! -e "$target" && ! -L "$target" ]]; then
    return
  fi

  mkdir -p "$BACKUP_DIR"
  rm -rf "$BACKUP_DIR/$backup_name"
  cp -a "$target" "$BACKUP_DIR/$backup_name"
}

install_lsd() {
  if command -v lsd >/dev/null 2>&1; then
    return
  fi

  if package_available lsd; then
    install_packages lsd
    return
  fi

  warn "Could not install lsd because the APT package is unavailable."
}

ensure_dmrc() {
  backup_path "$HOME/.dmrc"
  cat > "$HOME/.dmrc" <<'EOF'
[Desktop]
Session=bspwm
EOF
  chmod 0644 "$HOME/.dmrc"
}

ensure_rofi_theme_config() {
  local rofi_cfg="$HOME/.config/rofi/config.rasi"
  local theme_spotlight="$HOME/.config/rofi/themes/spotlight-dark.rasi"
  local theme_nord="$HOME/.config/rofi/themes/nord.rasi"

  if [[ ! -f "$rofi_cfg" ]]; then
    return
  fi

  sed -i \
    -e 's|@theme "/home/hacker/.local/share/rofi/themes/spotlight-dark.rasi"|@theme "~/.config/rofi/themes/spotlight-dark.rasi"|g' \
    -e 's|@theme "~/.local/share/rofi/themes/spotlight-dark.rasi"|@theme "~/.config/rofi/themes/spotlight-dark.rasi"|g' \
    "$rofi_cfg"

  if [[ ! -f "$theme_spotlight" && -f "$theme_nord" ]]; then
    warn "Rofi spotlight theme not found, switching to nord theme."
    sed -i 's|@theme "~/.config/rofi/themes/spotlight-dark.rasi"|@theme "~/.config/rofi/themes/nord.rasi"|g' "$rofi_cfg"
  fi
}

ensure_xsession_files() {
  backup_path "$HOME/.xsession"
  cat > "$HOME/.xsession" <<'EOF'
#!/bin/sh
exec bspwm
EOF
  chmod +x "$HOME/.xsession"

  backup_path "$HOME/.xinitrc"
  cat > "$HOME/.xinitrc" <<'EOF'
#!/bin/sh
exec bspwm
EOF
  chmod +x "$HOME/.xinitrc"
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

install_local_script() {
  local src="$1"
  local name="${2:-$(basename "$src")}"
  local dst="$HOME/.local/bin/$name"

  if [[ ! -f "$src" ]]; then
    warn "File does not exist: $src"
    return
  fi

  backup_named_path "local-bin-$name" "$dst"
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$src" "$dst"
}

log "Requesting sudo credentials..."
sudo -v

log "Updating system packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

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
  ca-certificates curl wget git unzip build-essential \
  xorg xinit dbus-x11 "$polkit_pkg" \
  bspwm sxhkd picom polybar rofi feh xclip scrot wmname acpi xdotool \
  kitty thunar network-manager net-tools \
  alsa-utils pulseaudio-utils \
  zsh zsh-syntax-highlighting zsh-autosuggestions neovim \
  xdg-utils imagemagick plocate

install_optional_packages \
  flameshot pipewire wireplumber playerctl bat fzf yazi zsh-autocomplete zsh-sudo \
  cmatrix ranger neofetch scrub \
  papirus-icon-theme \
  fonts-font-awesome \
  libnotify-bin

install_packages i3lock
install_lsd

if ! command -v starship >/dev/null 2>&1; then
  log "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if systemctl list-unit-files 2>/dev/null | grep -q '^NetworkManager\\.service'; then
  sudo systemctl enable --now NetworkManager >/dev/null 2>&1 || true
fi

if ! systemctl list-unit-files 2>/dev/null | grep -q '^display-manager\.service'; then
  warn "No display manager detected. Install one manually or start BSPWM with startx."
fi

log "Copying configurations to ~/.config ..."
mkdir -p "$HOME/.config"

log "Backing up existing Neovim directories (if present)..."
backup_named_path "nvim-config" "$HOME/.config/nvim"
backup_named_path "nvim-data" "$HOME/.local/share/nvim"
backup_named_path "nvim-state" "$HOME/.local/state/nvim"
backup_named_path "nvim-cache" "$HOME/.cache/nvim"
rm -rf "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"

log "Installing LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

copy_config_dir "$SCRIPT_DIR/Config/bspwm" "$HOME/.config/bspwm"
copy_config_dir "$SCRIPT_DIR/Config/sxhkd" "$HOME/.config/sxhkd"
copy_config_dir "$SCRIPT_DIR/Config/picom" "$HOME/.config/picom"
copy_config_dir "$SCRIPT_DIR/Config/polybar" "$HOME/.config/polybar"
copy_config_dir "$SCRIPT_DIR/Config/bin" "$HOME/.config/bin"
copy_config_dir "$SCRIPT_DIR/Config/kitty" "$HOME/.config/kitty"
copy_config_dir "$SCRIPT_DIR/rofi" "$HOME/.config/rofi"
copy_file_if_exists "$SCRIPT_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
ensure_rofi_theme_config
ensure_dmrc
ensure_xsession_files

log "Copying wallpapers and utilities..."
mkdir -p "$HOME/Wallpaper" "$HOME/ScreenShots"
if [[ -d "$SCRIPT_DIR/Wallpaper" ]]; then
  cp -af "$SCRIPT_DIR/Wallpaper/." "$HOME/Wallpaper/"
fi

install_local_script "$SCRIPT_DIR/scripts/wall"
install_local_script "$SCRIPT_DIR/scripts/file-manager-smart"

sudo install -m 0755 "$SCRIPT_DIR/scripts/whichSystem.py" /usr/local/bin/whichSystem.py
sudo install -m 0755 "$SCRIPT_DIR/scripts/screenshot" /usr/local/bin/screenshot

log "Installing fonts for the user..."
mkdir -p "$HOME/.local/share/fonts"
if [[ -d "$SCRIPT_DIR/fonts/HNF" ]]; then
  cp -af "$SCRIPT_DIR/fonts/HNF/." "$HOME/.local/share/fonts/"
fi
fc-cache -fv >/dev/null || true

log "Configuring ZSH and Starship..."

if [[ -f "$SCRIPT_DIR/.zshrc" ]]; then
  copy_file_if_exists "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
else
  cat > "$HOME/.zshrc" <<'ZSHRC'
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
ZSHRC
fi

if ! grep -q '^\[\[ \$- != \*i\* \]\] && return$' "$HOME/.zshrc" 2>/dev/null; then
  tmp_zshrc="$(mktemp)"
  {
    echo '[[ $- != *i* ]] && return'
    cat "$HOME/.zshrc"
  } > "$tmp_zshrc"
  mv "$tmp_zshrc" "$HOME/.zshrc"
fi

log "Keeping default login shell unchanged (recommended for BSPWM/display-manager stability)."
log "Use zsh manually in terminal when needed."

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
1) Log out and select BSPWM in your current display manager, or run `startx` if you do not use one.
2) Verify key dependencies:
   bspwm --version && sxhkd -v && polybar --version && picom --version

MSG
