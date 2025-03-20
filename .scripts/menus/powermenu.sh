#!/bin/env bash

choice=$(printf "󰍃  Logout\n  Reboot\n  Shutdown\n  Lock\n󰒲  Suspend" | rofi -dmenu -p "⏻ Power: ")

case "$choice" in
  "󰍃  Logout") pkill -KILL -u "$USER" ;;
  "  Reboot") systemctl reboot ;;
  "  Shutdown") systemctl poweroff ;;
  "  Lock") sh $HOME/bin/screen-lock.sh ;;
  "󰒲  Suspend") sh $HOME/bin/screen-lock.sh --suspend ;;
esac
