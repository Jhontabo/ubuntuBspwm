#!/bin/bash

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
ln -s ~/ubuntuBspwm/Config/bspwm ~/.config/bspwm
ln -s ~/ubuntuBspwm/Config/polybar ~/.config/polybar
ln -s ~/ubuntuBspwm/Config/sxhkd ~/.config/sxhkd
ln -s ~/ubuntuBspwm/Config/picom ~/.config/picom
ln -s ~/ubuntuBspwm/Config/bin ~/.config/bin
ln -s ~/ubuntuBspwm/Config/kitty ~/.config/kitty

# Symlinks para archivos sueltos
ln -sf ~/ubuntuBspwm/.zshrc ~/.zshrc
ln -sf ~/ubuntuBspwm/.p10k.zsh ~/.p10k.zsh

echo "Symlinks creados!"
