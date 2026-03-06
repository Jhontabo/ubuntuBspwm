#!/bin/sh

ip_target="$(awk '{print $1}' ~/.config/bin/target 2>/dev/null)"
name_target="$(awk '{print $2}' ~/.config/bin/target 2>/dev/null)"

	if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
	echo "%{F#cf9fff}什%{F#ffffff} $ip_target - $name_target"
	elif [ "$(wc -w < ~/.config/bin/target 2>/dev/null)" -eq 1 ] 2>/dev/null; then
	echo "%{F#cf9fff}什%{F#ffffff} $ip_target"
	else
	echo "%{F#cf9fff}ﲅ %{u-}%{F#ffffff} No target"
	fi
