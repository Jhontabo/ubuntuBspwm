#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "Creando symlinks..."

# Respaldar configs existentes
mkdir -p ~/.config-backup
[ -d ~/.config/bspwm ] && cp -r ~/.config/bspwm ~/.config-backup/
[ -d ~/.config/polybar ] && cp -r ~/.config/polybar ~/.config-backup/
[ -d ~/.config/sxhkd ] && cp -r ~/.config/sxhkd ~/.config-backup/
[ -d ~/.config/picom ] && cp -r ~/.config/picom ~/.config-backup/
[ -d ~/.config/bin ] && cp -r ~/.config/bin ~/.config-backup/
[ -d ~/.config/kitty ] && cp -r ~/.config/kitty ~/.config-backup/

# Eliminar carpetas existentes
rm -rf ~/.config/bspwm ~/.config/polybar ~/.config/sxhkd ~/.config/picom ~/.config/bin ~/.config/kitty

# Crear symlinks
ln -s "$REPO_DIR/Config/bspwm" ~/.config/bspwm
ln -s "$REPO_DIR/Config/polybar" ~/.config/polybar
ln -s "$REPO_DIR/Config/sxhkd" ~/.config/sxhkd
ln -s "$REPO_DIR/Config/picom" ~/.config/picom
ln -s "$REPO_DIR/Config/bin" ~/.config/bin
ln -s "$REPO_DIR/Config/kitty" ~/.config/kitty

# Symlinks para archivos sueltos
ln -sf "$REPO_DIR/.zshrc" ~/.zshrc
ln -sf "$REPO_DIR/.p10k.zsh" ~/.p10k.zsh

echo "Symlinks creados!"
