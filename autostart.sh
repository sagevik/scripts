#! /bin/sh

# Keyboard layout
setxkbmap no -option
xmodmap ~/.Xmodmap

# Screen resolution
xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal &

# Compositor
picom --config $HOME/.config/picom/picom.conf &

# Statusbar
slstatus &

# wallpaper
xwallpaper --zoom $HOME/.local/share/background/wp.png

# Updates
archupdate -b &

# Systray
nm-applet &
blueman-applet &

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Volume in statusbar
volume init &

# Restart loop
while true; do
    dwm >/dev/null 2>&1
done

# Execute dwm
exec dwm

