#!/usr/bin/env bash

font="Hack:size=16"
wayfont="Hack Bold 24"

notify() {
  notify-send "Power Profile" "Set to $1"
}

get_profile() {
    profile=$(powerprofilesctl get)
    case "$profile" in
        "balanced")
            icon="⚖️"
            text="Balanced"
            ;;
        "performance")
            icon="⚡"
            text="Performance"
            ;;
        "power-saver")
            icon="♻️"
            text="Power Saver"
            ;;
        *)
            icon="❓"
            text="Unknown"
            ;;
    esac
    # Output just the icon by default. 
    # For icon + text: echo "{\"text\": \"$icon $text\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
    # For just text: echo "{\"text\": \"$text\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
    # echo "{\"text\": \"$icon\", \"tooltip\": \"Power Profile: $text\", \"class\": \"$profile\"}"
    echo "$icon"
}

if [ "$1" = "get" ]; then
  get_profile
  exit 0
fi

# declare -A profiles=(
#     ["⚖️ Balanced"]="balanced"
#     ["⚡ Performance"]="performance"
#     ["♻️ Power saver"]="power-saver"
# )

declare -A profiles=(
    ["⚖️ Balanced"]="balanced"
    ["⚡ Performance"]="performance"
    ["♻️ Power saver"]="power-saver"
)

get_current_profile_key() {
    local current_value
    current_value=$(powerprofilesctl get)
    for key in "${!profiles[@]}"; do
        if [ "${profiles[$key]}" = "$current_value" ]; then
            echo "$key"
            return
        fi
    done
    echo "Unknown"
}

build_menu() {
    local current
    current=$(powerprofilesctl get)      # e.g. "balanced"

    for key in "${!profiles[@]}"; do
        if [ "${profiles[$key]}" = "$current" ]; then
            printf '* %s\n' "$key"
        else
            printf '%s\n' "$key"
        fi
    done
}

run_dmenu() {
    local current_profile
    current_profile=$(get_current_profile_key)
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        build_menu | sort | wmenu -f "$wayfont" -c -i -l "${#profiles[@]}" $WMENU_COLORS -p "Profile"
        # build_menu | sort | rofi -dmenu -i -l "${#profiles[@]}" -p "Profile (current: $current_profile)"
        # printf "%s\n" "${!profiles[@]}" | sort | rofi -dmenu -i -l "${#profiles[@]}" -p "Profile (current: $current_profile)"
    else
        build_menu | sort | dmenu -fn "$font" -i -c -l "${#profiles[@]}" -p "Profile"
        # printf "%s\n" "${!profiles[@]}" | sort | dmenu -fn "Hack:size=16" -i -c -l "${#profiles[@]}" -p "Profile (current: $current_profile)"
    fi
}

chosen=$(run_dmenu)
[ -z "$chosen" ] && exit 0

if [[ -n "${profiles[$chosen]}" ]]; then
    powerprofilesctl set "${profiles[$chosen]}"
    notify "${profiles[$chosen]}"
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        # hyprctl reload
        pkill -RTMIN+8 waybar
    else
        pkill -RTMIN+5 slstatus
    fi
fi


# -------------------

# notify() {
#   notify-send "Power Profile" "Set to $1"
# }
#
# get_profile() {
#     profile=$(powerprofilesctl get)
#     case "$profile" in
#         "balanced")      icon="⚖️"; text="Balanced" ;;
#         "performance")   icon="⚡"; text="Performance" ;;
#         "power-saver")   icon="♻️"; text="Power Saver" ;;
#         *)               icon="❓"; text="Unknown" ;;
#     esac
#     echo "$icon"
# }
#
# if [ "$1" = "get" ]; then
#   get_profile
#   exit 0
# fi
#
# declare -A profiles=(
#     ["⚖️ Balanced"]="balanced"
#     ["⚡ Performance"]="performance"
#     ["♻️ Power saver"]="power-saver"
# )
#
# # -------------------------------------------------
# # 1. Build a menu line for every entry.
# #    The current profile gets a trailing " *"
# # -------------------------------------------------
# build_menu() {
#     local current
#     current=$(powerprofilesctl get)      # e.g. "balanced"
#
#     for key in "${!profiles[@]}"; do
#         if [ "${profiles[$key]}" = "$current" ]; then
#             printf '* %s\n' "$key"
#         else
#             printf '%s\n' "$key"
#         fi
#     done
# }
#
# run_dmenu() {
#     if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
#         build_menu | sort | rofi -dmenu -i -l "${#profiles[@]}" -p "Profile"
#     else
#         build_menu | sort | dmenu -fn "Hack:size=16" -i -c -l "${#profiles[@]}" -p "Profile"
#     fi
# }
# # -------------------------------------------------
#
# chosen=$(run_dmenu)
# [ -z "$chosen" ] && exit 0
#
# # Strip the optional trailing " *"
# chosen_clean="${chosen% *}"
#
# if [[ -n "${profiles[$chosen_clean]}" ]]; then
#     powerprofilesctl set "${profiles[$chosen_clean]}"
#     notify "${profiles[$chosen_clean]}"
#     if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
#         hyprctl reload
#         pkill -RTMIN+8 waybar
#     else
#         pkill -RTMIN+5 slstatus
#     fi
# fi
