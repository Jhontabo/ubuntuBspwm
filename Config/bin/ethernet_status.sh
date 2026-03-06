#!/bin/sh

IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"
IP_ADDR=""

if [ -n "$IFACE" ]; then
  IP_ADDR="$(ip -o -4 addr show dev "$IFACE" | awk '{print $4}' | cut -d/ -f1 | head -n1)"
fi

if [ -n "$IP_ADDR" ]; then
  echo "%{F#7dcfff} %{F#ffffff}${IP_ADDR}%{u-}"
else
  echo "%{F#7dcfff} %{F#ffffff}Disconnected%{u-}"
fi
