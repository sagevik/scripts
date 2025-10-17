#!/bin/sh

# Function to check and create symlink for colorscheme
ensure_colorscheme_symlink() {
  local colors_dir="$HOME/.config/sucklesscolors"
  local current_symlink="$colors_dir/current"
  local default_colorscheme="$colors_dir/dwmblue"

  # Check if the current symlink exists
  if [ ! -L "$current_symlink" ]; then
    # Ensure the default colorscheme file exists
    if [ -f "$default_colorscheme" ]; then
      ln -sf "$default_colorscheme" "$current_symlink"
      echo "Created symlink: $current_symlink -> $default_colorscheme"
    else
      echo "Error: Default colorscheme $default_colorscheme does not exist" >&2
      return 1
    fi
  fi
}

ensure_colorscheme_symlink &

# Keyboard layout
setxkbmap no -option
xmodmap ~/.Xmodmap

# Key repeat
xset r rate 250 30

# Screen resolution
sh "$HOME/scripts/bin/setup_display.sh" &

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

# Notification
dunst &

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Volume in statusbar
volume init &

# Restart loop
while true; do
  # merge X resources
  if [ -f ~/.config/sucklesscolors/current ]; then
    xrdb -merge $HOME/.Xresourses
    xrdb -merge ~/.config/sucklesscolors/current
  fi
  dwm >/dev/null 2>&1
done

# Execute dwm
exec dwm
