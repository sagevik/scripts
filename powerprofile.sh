#!/usr/bin/env bash

# Declare associative array for power profiles
declare -A profiles=(
    ["Balanced"]="balanced"
    ["Performance"]="performance"
    ["Power saver"]="power-saver"
)

# Function to get the current profile key from its value
get_current_profile_key() {
    local current_value
    current_value=$(powerprofilesctl get)  # Get current profile (e.g., "balanced")
    for key in "${!profiles[@]}"; do
        if [ "${profiles[$key]}" = "$current_value" ]; then
            echo "$key"
            return
        fi
    done
    echo "Unknown"  # Fallback if no match
}

# Pass profile keys to rofi (sorted) with current profile in prompt
run_dmenu() {
    local current_profile
    current_profile=$(get_current_profile_key)
    printf "%s\n" "${!profiles[@]}" | sort | rofi -dmenu -i -l "${#profiles[@]}" -p "Select Power Profile (current: $current_profile)"
}

# Get user selection
chosen=$(run_dmenu)

if [ -z "$chosen" ]; then
    exit 0
else
    # Check if chosen key exists in profiles array
    if [[ -n "${profiles[$chosen]}" ]]; then
        powerprofilesctl set "${profiles[$chosen]}"
        pkill -RTMIN+8 waybar
        hyprctl reload
    else
        exit 0  # Exit silently if no selection or invalid key
    fi
fi
