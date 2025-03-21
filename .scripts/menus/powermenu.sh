#!/bin/bash

choice=$(printf "󰍃\n\n" | rofi -dmenu -theme "~/.config/rofi/powermenu.rasi")

case "$choice" in
  "󰍃") pkill -KILL -u "$USER" ;;
  "") systemctl reboot ;;
  "") systemctl poweroff ;;
esac
