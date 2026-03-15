#!/usr/bin/env sh

detect_battery() {
  for path in /sys/class/power_supply/*; do
    [ -e "$path" ] || return 1
    name=${path##*/}
    case "$name" in
      BAT*)
        printf '%s\n' "$name"
        return 0
        ;;
    esac
  done

  return 1
}

detect_adapter() {
  for path in /sys/class/power_supply/*; do
    [ -e "$path" ] || return 1
    name=${path##*/}
    case "$name" in
      AC|ACAD|ADP*|ADAPTER*|Mains)
        printf '%s\n' "$name"
        return 0
        ;;
    esac
  done

  return 1
}

detect_mixer() {
  command -v amixer >/dev/null 2>&1 || return 1

  controls=$(amixer scontrols 2>/dev/null | sed -n "s/^Simple mixer control '\(.*\)',.*/\1/p")
  [ -n "$controls" ] || return 1

  for preferred in Master Speaker Headphone PCM; do
    found=$(printf '%s\n' "$controls" | grep -Fx "$preferred" | head -n 1)
    if [ -n "$found" ]; then
      printf '%s\n' "$found"
      return 0
    fi
  done

  printf '%s\n' "$controls" | head -n 1
}

killall -q polybar 2>/dev/null || true
while pgrep -x polybar >/dev/null; do sleep 1; done

BATTERY_NAME=$(detect_battery || true)
ADAPTER_NAME=$(detect_adapter || true)
MIXER_NAME=$(detect_mixer || true)

if [ -n "$BATTERY_NAME" ] && [ -n "$ADAPTER_NAME" ]; then
  export POLYBAR_BATTERY="$BATTERY_NAME"
  export POLYBAR_ADAPTER="$ADAPTER_NAME"
  export POLYBAR_RIGHT_MODULES="wifi volume cpu ram battery date powermenu"
else
  unset POLYBAR_BATTERY POLYBAR_ADAPTER
  export POLYBAR_RIGHT_MODULES="wifi volume cpu ram date powermenu"
fi

if [ -n "$MIXER_NAME" ]; then
  export POLYBAR_MIXER="$MIXER_NAME"
fi

polybar main -c ~/.config/polybar/pacman.ini &

printf 'Polybar iniciada con estetica Pac-Man\n'
