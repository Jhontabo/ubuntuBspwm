#!/bin/sh

IFACE="$(ip -o link show | awk -F': ' '{print $2}' | grep '^tun0$' || true)"

if [ "$IFACE" = "tun0" ]; then
	TUN_IP="$(ip -o -4 addr show dev tun0 | awk '{print $4}' | cut -d/ -f1 | head -n1)"
	echo "%{F#7dcfff} %{F#ffffff}${TUN_IP}%{u-}"
else
	echo "%{F#7dcfff}%{u-} Disconnected"
fi
