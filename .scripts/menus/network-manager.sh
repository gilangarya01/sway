#!/bin/bash

# Global constants
SESSION_TYPE="$XDG_SESSION_TYPE"
ENABLED_COLOR="#41a6b5"      # Color for enabled status
DISABLED_COLOR="#ff757f"      # Color for disabled status
SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")    # Icons for different signal strengths
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ") # Icons for secured signals
WIFI_CONNECTED_ICON=" "      # Icon for connected Wi-Fi
WIFI_DISABLED_ICON="  "     # Icon for disabled Wi-Fi
WIFI_TOGGLE_ON_ICON="󱚽  "     # Icon for enable wifi
WIFI_TOGGLE_OFF_ICON="󱛅  "    # Icon for disable wifi
WIFI_MANAGE_ICON="󱓥  "       # Icon for manage wifi
WIFI_CONNECT_ICON="󰸋  "      # Icon for connect wifi
WIFI_DISCONNECT_ICON="  "    # Icon for disconnect wifi
WIFI_FORGET_ICON="  "        # Icon for forget wifi

# Function to get the status of the current network connection
get_status() {
    local wifi_info
    wifi_info=$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no | grep '\*')

    if [[ -n "$wifi_info" ]]; then
        IFS=: read -r in_use signal security ssid <<< "$wifi_info"
        local signal_level=$((signal / 25))
        local signal_icon="${SIGNAL_ICONS[3]}"

        if [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]]; then
            signal_icon="${SIGNAL_ICONS[$signal_level]}"
        fi
        if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
            signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
        fi
        echo "<span color=\"$ENABLED_COLOR\">$signal_icon</span>"
    else
        echo "<span color=\"$DISABLED_COLOR\">$WIFI_DISABLED_ICON</span>"
    fi
}

# Function to manage Wi-Fi connections
manage_wifi() {
    local wifi_list formatted_ssids ssids

    IFS=$'\n' read -r -d '' -a wifi_list <<< "$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no)"

    for wifi_info in "${wifi_list[@]}"; do
        IFS=: read -r in_use signal security ssid <<< "$wifi_info"
        if [[ -z "$ssid" ]]; then continue; fi # Skip empty SSID

        local signal_level=$((signal / 25))
        local signal_icon="${SIGNAL_ICONS[3]}"

        if [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]]; then
            signal_icon="${SIGNAL_ICONS[$signal_level]}"
        fi
        if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
            signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
        fi

        local formatted="$signal_icon $ssid"
        if [[ "$in_use" =~ \* ]]; then
            formatted="$WIFI_CONNECTED_ICON $formatted"
        fi
        formatted_ssids+=("$formatted")
        ssids+=("$ssid")
    done

    local chosen_network
    chosen_network=$(printf "%s\n" "${formatted_ssids[@]}" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: ")

    if [[ -z "$chosen_network" ]]; then
        return
    fi

    local ssid_index
    for i in "${!formatted_ssids[@]}"; do
        if [[ "${formatted_ssids[$i]}" == "$chosen_network" ]]; then
            ssid_index=$i
            break
        fi
    done

    local chosen_ssid="${ssids[$ssid_index]}"

    local action
    if [[ "$chosen_ssid" == "$ssid" ]]; then
        action="$WIFI_DISCONNECT_ICON Disconnect"
    else
        action="$WIFI_CONNECT_ICON Connect"
    fi

    action=$(echo -e "$action\n$WIFI_FORGET_ICON Forget" | rofi -dmenu -p "Action: ")
    case $action in
        "$WIFI_CONNECT_ICON Connect")
            connect_to_wifi "$chosen_ssid"
            ;;
        "$WIFI_DISCONNECT_ICON Disconnect")
            nmcli device disconnect wlan0 && notify-send "Disconnected" "You have been disconnected from $chosen_ssid."
            ;;
        "$WIFI_FORGET_ICON Forget")
            nmcli connection delete id "$chosen_ssid" && notify-send "Forgotten" "The network $chosen_ssid has been forgotten."
            ;;
    esac
}

# Function to connect to Wi-Fi with optional password
connect_to_wifi() {
    local ssid="$1"
    local success_message="You are now connected to the Wi-Fi network \"$ssid\"."

    if nmcli connection show | grep -q "$ssid"; then
        nmcli connection up id "$ssid" && notify-send "Connection Established" "$success_message"
    else
        local wifi_password
        wifi_password=$(rofi -dmenu -p "Password: " -password)
        nmcli device wifi connect "$ssid" password "$wifi_password" && notify-send "Connection Established" "$success_message"
    fi
}

# Main menu function
main_menu() {
    local status_mode=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                status_mode=true
                shift
                ;;
            --enabled-color)
                ENABLED_COLOR="$2"
                shift 2
                ;;
            --disabled-color)
                DISABLED_COLOR="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if "$status_mode"; then
        get_status
        return
    fi

    local wifi_status
    wifi_status=$(nmcli -fields WIFI g)

    local wifi_toggle
    local wifi_toggle_command
    local manage_wifi_btn

    if [[ "$wifi_status" =~ "enabled" ]]; then
        wifi_toggle="$WIFI_TOGGLE_OFF_ICON Disable Wi-Fi"
        wifi_toggle_command="off"
        manage_wifi_btn="\n$WIFI_MANAGE_ICON Manage Wi-Fi"
    else
        wifi_toggle="$WIFI_TOGGLE_ON_ICON Enable Wi-Fi"
        wifi_toggle_command="on"
        manage_wifi_btn=""
    fi

    local chosen_option
    chosen_option=$(echo -e "$wifi_toggle$manage_wifi_btn" | rofi -dmenu -p " Network: ")

    case $chosen_option in
        "$WIFI_TOGGLE_ON_ICON Enable Wi-Fi" | "$WIFI_TOGGLE_OFF_ICON Disable Wi-Fi")
            nmcli radio wifi "$wifi_toggle_command" && notify-send "Wi-Fi Toggled" "Wi-Fi has been turned ${wifi_toggle_command}."
            ;;
        "$WIFI_MANAGE_ICON Manage Wi-Fi")
            manage_wifi
            ;;
    esac
}

main_menu "$@"
