#!/bin/sh

usbmon() {
	usb1=$(lsblk -la | awk '/sdc1/ { print $1 }')
	usb1mounted=$(lsblk -la | awk '/sdc1/ { print $7 }')

	if [ "$usb1" ]; then
		if [ -z "$usb1mounted" ]; then
			echo " |"
		else
			echo " $usb1 |"
		fi
	fi
}

battery(){
if [[ ! -d /sys/class/power_supply/BAT0 ]]; then
    printf "󱉞"
    exit
fi

# File to track battery full status
status_file="/tmp/battery_status"

# Check battery capacity and charge status
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
battery_charge_status=$(cat /sys/class/power_supply/BAT0/status)

batstat=""
case $battery_charge_status in
    "Full")
	if [ "$(cat $status_file 2>/dev/null)" != "Full" ]; then
            notify-send "󰂄 Battery fully charged" "You can disconnect the charger"
	fi
	;;
esac

# Update status file
echo "$battery_charge_status" > "$status_file"

bat=""

if [ "$battery_charge_status" = "Charging" ]; then
    bat="󰂄"
else
    if [ "$battery_capacity" -ge 90 ]; then
        bat="󰂂"
    elif [ "$battery_capacity" -ge 80 ]; then
        bat="󰂁"
    elif [ "$battery_capacity" -ge 70 ]; then
        bat="󰂀"
    elif [ "$battery_capacity" -ge 60 ]; then
        bat="󰁿"
    elif [ "$battery_capacity" -ge 50 ]; then
        bat="󰁾"
    elif [ "$battery_capacity" -ge 40 ]; then
        bat="󰁽"
    elif [ "$battery_capacity" -ge 30 ]; then
        bat="󰁼"
    elif [ "$battery_capacity" -ge 20 ]; then
        bat="󰁻"
    elif [ "$battery_capacity" -ge 10 ]; then
        bat="󰁺"
    else
        notify-send --urgency=critical " Battery critical" "Charge your computer"
        bat="󰂎"
    fi
fi

printf "$bat $battery_capacity%%"

}

batt() {
	_batt=$(cat /sys/class/power_supply/BAT0/capacity)

	if [ "${_batt}" -gt 75 ]; then
		echo " ${_batt}%"
	elif [ "${_batt}" -gt 50 ]; then
		echo " ${_batt}%"
	elif [ "${_batt}" -gt 25 ]; then
		echo " ${_batt}%"
	elif [ "${_batt}" -lt 25 ]; then
		echo " ${_batt}%"
	elif [ "${_batt}" -lt 10 ]; then
		echo " ${_batt}%"
	fi
}

ram() {
	mem=$(free -h | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	echo  "$mem"
}

cpu() {
	read -r cpu a b c previdle rest < /proc/stat
	prevtotal=$((a+b+c+previdle))
	echo "prevtotal $prevtotal"
	sleep 0.5
	read -r cpu a b c idle rest < /proc/stat
	total=$((a+b+c+idle))
	echo "total $total"
	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	echo  "$cpu"%
}

network() {
    # Check for Ethernet (e) and WiFi (w) in default routes
    ethernet=$(ip route | awk '/default/ {if (substr($5,1,1) == "e") {print "e"; exit}}')
    wifi=$(ip route | awk '/default/ {if (substr($5,1,1) == "w") {print "w"; exit}}')

    # Initialize output strings
    eth_status="󰈂"
    wifi_status="󰖪"

    # Set status based on connection type
    [ "$ethernet" = "e" ] && eth_status="󰈁"
    [ "$wifi" = "w" ] && wifi_status="󰖩"

    echo "$eth_status/$wifi_status"
}

volume() {
	def=$(pactl get-default-sink)
	muted=$(pactl get-sink-mute "$def" | awk '/Mute:/ { print $2 }')
	vol=$(pactl get-sink-volume "$def" | sed -n 's/.* \([0-9]\+\)% .*/\1/p; s/.* \([0-9]\+\)%$/\1/p')

	if [ "$muted" = "yes" ]; then
		echo " mute"
	else
		if [ "$vol" -ge 65 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 40 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 0 ]; then
			echo " $vol%"	
		fi
	fi
}

clock() {
	time=$(date +"%Y-%m-%d %H:%M")
	echo " $time"
}

package_updates() {
	echo " :  $(cat /tmp/packageUpdates)"
}

main() {
	while true; do
		# xsetroot -name " $(usbmon) $(batt) | $(ram) | $(cpu) | $(network) | $(volume) | $(clock)"
		echo "$(package_updates)  $(volume)  $(battery)  $(network)  $(clock)"
		sleep 1
	done
}

main

