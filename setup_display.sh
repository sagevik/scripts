#!/bin/sh

# Check for external display and available modes
if xrandr | grep -q "DP-1 connected"; then
    # Check if 5120x1440 is an available mode for DP-1
    if xrandr --query | grep -A10 "DP-1 connected" | grep -q "5120x1440"; then
        xrandr --output DP-0 --off --output DP-1 --primary --mode 5120x1440 --pos 1920x0 --rotate normal --output HDMI-0 --off --output eDP-1-1 --mode 1920x1080 --pos 0x360 --rotate normal
    else
        # Get the preferred resolution for DP-1
        PREFERRED_MODE=$(xrandr --query | grep -A1 "DP-1 connected" | grep "+" | awk '{print $1}')
        if [ -n "$PREFERRED_MODE" ]; then
            xrandr --output DP-0 --off --output DP-1 --primary --mode "$PREFERRED_MODE" --pos 0x0 --rotate normal --output HDMI-0 --off --output eDP-1-1 --off
        else
            xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal
        fi
    fi
else
    xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal
fi

wallpaper --reload
