#!/bin/bash

# Global constants
SESSION_TYPE="$XDG_SESSION_TYPE"
ENABLED_COLOR="#A3BE8C"       # Color for enabled status
DISABLED_COLOR="#D35F5E"      # Color for disabled status
SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")     # Icons for different signal strengths
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ")  # Icons for secured signals
WIFI_CONNECTED_ICON=" "      # Icon for connected Wi-Fi
ETHERNET_CONNECTED_ICON=" "  # Icon for connected Ethernet

# Function to get the status of the current network connection
get_status() {
    # Check Ethernet connection status
    if nmcli -t -f TYPE,STATE device status | grep -q 'ethernet:connected'; then
        echo "<span color=\"$ENABLED_COLOR\">󰈀</span>"
        return
    fi

    # Check Wi-Fi connection status
    local wifi_info
    wifi_info=$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no | grep '\*')
    
    if [[ -n "$wifi_info" ]]; then
        # Extract relevant details for Wi-Fi connection
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
        echo "<span color=\"$DISABLED_COLOR\">  </span>"
    fi
}

# Function to manage Wi-Fi connections
manage_wifi() {
    local wifi_list formatted_ssids ssids

    # List available Wi-Fi networks directly in bash without creating temporary files
    IFS=$'\n' read -r -d '' -a wifi_list <<< "$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no)"

    for wifi_info in "${wifi_list[@]}"; do
        IFS=: read -r in_use signal security ssid <<< "$wifi_info"
        if [[ -z "$ssid" ]]; then continue; fi  # Skip empty SSID

        local signal_level=$((signal / 25))
        local signal_icon="${SIGNAL_ICONS[3]}"

        if [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]]; then
            signal_icon="${SIGNAL_ICONS[$signal_level]}"
        fi
        if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
            signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
        fi

        # Format SSID with connection status icon
        local formatted="$signal_icon $ssid"
        if [[ "$in_use" =~ \* ]]; then
            formatted="$WIFI_CONNECTED_ICON $formatted"
        fi
        formatted_ssids+=("$formatted")
        ssids+=("$ssid")
    done

    # Present the formatted list of Wi-Fi networks to the user using Rofi
    local chosen_network
    chosen_network=$(printf "%s\n" "${formatted_ssids[@]}" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: ")

    # If no network was selected, exit
    if [[ -z "$chosen_network" ]]; then
        return
    fi

    # Find the corresponding SSID and determine action (Connect/Disconnect)
    local ssid_index
    for i in "${!formatted_ssids[@]}"; do
        if [[ "${formatted_ssids[$i]}" == "$chosen_network" ]]; then
            ssid_index=$i
            break
        fi
    done

    local chosen_ssid="${ssids[$ssid_index]}"

    # Check the device status and perform actions
    local action
    if [[ "$chosen_ssid" == "$ssid" ]]; then
        action="  Disconnect"
    else
        action="󰸋  Connect"
    fi

    action=$(echo -e "$action\n  Forget" | rofi -dmenu -p "Action: ")
    case $action in
        "󰸋  Connect")
            connect_to_wifi "$chosen_ssid"
            ;;
        "  Disconnect")
            nmcli device disconnect wlan0 && notify-send "Disconnected" "You have been disconnected from $chosen_ssid."
            ;;
        "  Forget")
            nmcli connection delete id "$chosen_ssid" && notify-send "Forgotten" "The network $chosen_ssid has been forgotten."
            ;;
    esac
}

# Function to connect to Wi-Fi with optional password
connect_to_wifi() {
    local ssid="$1"
    local success_message="You are now connected to the Wi-Fi network \"$ssid\"."
    
    # Check if the network is already saved
    if nmcli connection show | grep -q "$ssid"; then
        nmcli connection up id "$ssid" && notify-send "Connection Established" "$success_message"
    else
        local wifi_password
        wifi_password=$(rofi -dmenu -p "Password: " -password)
        nmcli device wifi connect "$ssid" password "$wifi_password" && notify-send "Connection Established" "$success_message"
    fi
}

# Function to manage Ethernet connections
manage_ethernet() {
    # Get the status of all Ethernet devices
    local eth_devices eth_list chosen_device device_status
    eth_devices=$(nmcli device status | grep ethernet | awk '{print $1}')

    if [[ -z "$eth_devices" ]]; then
        notify-send "Error" "Ethernet device not found."
        return
    fi

    # Prepare Ethernet device list for selection
    for dev in $eth_devices; do
        device_status=$(nmcli device status | grep "$dev" | awk '{print $3}')
        if [[ "$device_status" == "connected" ]]; then
            eth_list+="$ETHERNET_CONNECTED_ICON$dev\n"
        else
            eth_list+="$dev\n"
        fi
    done

    # Allow the user to select an Ethernet device
    chosen_device=$(echo -e "$eth_list" | rofi -dmenu -i -p "Select Ethernet device: ")

    # Exit if no device was selected
    if [[ -z "$chosen_device" ]]; then
        return
    fi

    # Determine the status of the chosen device
    chosen_device=$(echo "$chosen_device" | sed "s/$ETHERNET_CONNECTED_ICON//")
    device_status=$(nmcli device status | grep "$chosen_device" | awk '{print $3}')

    # Perform action based on the device's connection status
    if [[ "$device_status" == "connected" ]]; then
        nmcli device disconnect "$chosen_device" && notify-send "Disconnected" "You have been disconnected from $chosen_device."
    elif [[ "$device_status" == "disconnected" ]]; then
        nmcli device connect "$chosen_device" && notify-send "Connected" "You are now connected to $chosen_device."
    else
        notify-send "Error" "Unable to determine the action for $chosen_device."
    fi
}

# Main menu function
main_menu() {
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

    if [[ $status_mode == true ]]; then
        get_status
        exit 1
    fi

    # Check if NetworkManager is running, start it if not
    if ! pgrep -x "NetworkManager" > /dev/null; then
        echo -n "Root Password: "
        read -s password
        echo "$password" | sudo -S systemctl start NetworkManager
    fi

    # Get the Wi-Fi status
    local wifi_status
    wifi_status=$(nmcli -fields WIFI g)

    # Toggle Wi-Fi based on its current state
    local wifi_toggle
    if [[ "$wifi_status" =~ "enabled" ]]; then
        wifi_toggle="󱛅  Disable Wi-Fi"
        wifi_toggle_command="off"
        manage_wifi_btn="\n󱓥 Manage Wi-Fi"
    else
        wifi_toggle="󱚽  Enable Wi-Fi"
        wifi_toggle_command="on"
        manage_wifi_btn=""
    fi

    # Show the network management menu
    local chosen_option
    chosen_option=$(echo -e "$wifi_toggle$manage_wifi_btn\n󱓥 Manage Ethernet" | rofi -dmenu -p " Network: ")
    
    case $chosen_option in
        "$wifi_toggle")
            nmcli radio wifi $wifi_toggle_command
            ;;
        "󱓥 Manage Wi-Fi")
            manage_wifi
            ;;
        "󱓥 Manage Ethernet")
            manage_ethernet
            ;;
    esac
}

main_menu "$@"
