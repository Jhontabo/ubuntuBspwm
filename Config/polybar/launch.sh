#!/usr/bin/env sh

## =============================================================================
## SCRIPT DE LANZAMIENTO DE POLYBAR - ESTÉTICA PAC-MAN
## =============================================================================

# Terminar instancias de polybar que ya están corriendo
killall -q polybar

# Esperar hasta que los procesos se hayan cerrado completamente
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar barra principal con configuración Pac-Man
polybar main -c ~/.config/polybar/current.ini &

echo "Polybar iniciada con estética Pac-Man"
