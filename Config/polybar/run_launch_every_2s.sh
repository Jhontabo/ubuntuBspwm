#!/bin/bash

while true; do
    killall -q polybar
    while pgrep -u $UID polybar >/dev/null; do sleep 1; done
    ~/.config/polybar/launch.sh &
    sleep 2
done
