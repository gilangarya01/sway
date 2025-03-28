#!/bin/bash

choice=$(printf "󰍃\n\n\n\n\n" | rofi -dmenu -p "⏻  Powermenu: " -theme "~/.config/rofi/powermenu.rasi")

case "$choice" in
  "󰍃") pkill -KILL -u "$USER" ;;
  "") systemctl reboot ;;
  "") systemctl poweroff ;;
  "") ;;
  "") ;;
  "") ;;
esac
