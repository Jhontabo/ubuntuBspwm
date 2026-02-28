#!/usr/bin/env sh

## =============================================================================
## SCRIPT DE LANZAMIENTO DE POLYBAR
## =============================================================================
## Este script inicia múltiples instancias de polybar con diferentes configuraciones
## para crear barras de estado modulares posicionadas en diferentes partes de la pantalla
## 
## ERRORES ENCONTRADOS Y CORREGIDOS:
## - Las barras 'log', 'quaternary', 'quinary' no estaban definidas en current.ini
## - Ahora solo se inicializan las barras que existen en los archivos de configuración
## =============================================================================

# Terminar instancias de polybar que ya están corriendo
killall -q polybar

# Esperar hasta que los procesos se hayan cerrado completamente
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# =============================================================================
# LANZAR BARRAS DESDE current.ini
# =============================================================================
# current.ini define barras modulares pequeñas posicionadas en diferentes puntos
# de la pantalla (diseño estilo 'dashboard')
#
# Barras disponibles en current.ini:
# - bar/primary:   Menú del sistema (esquina superior derecha)
# - bar/secondary: Fecha y hora (izquierda)
# - bar/terciary:  Estado ethernet (centro-izquierda)
# - bar/top:       Control de volumen (esquina superior)
# - bar/main:      Configuración base (no es una barra, es plantilla)
#

# ERROR: Las siguientes barras estaban referenciadas pero NO existen en current.ini:
#   - log         (eliminado)
#   - quaternary  (eliminado)
#   - quinary     (eliminado)

# Barra de menú del sistema (derecha)
polybar primary -c ~/.config/polybar/current.ini &

# Barra de fecha/hora (izquierda)
polybar secondary -c ~/.config/polybar/current.ini &

# Barra de estado ethernet (centro-izquierda)
polybar terciary -c ~/.config/polybar/current.ini &

# Barra de control de volumen (esquina superior)
polybar top -c ~/.config/polybar/current.ini &

# =============================================================================
# LANZAR BARRAS DESDE workspace.ini
# =============================================================================
# workspace.ini define barras para workspaces y título de ventana
#
# Barras disponibles en workspace.ini:
# - bar/primary:   Muestra workspaces (esquina inferior)
# - bar/secondary: Muestra nombre de escritorio y título de ventana
#

# Barra de workspaces (esquina inferior)
polybar primary -c ~/.config/polybar/workspace.ini &

# Barra de información de ventana (título y nombre)
polybar secondary -c ~/.config/polybar/workspace.ini &
