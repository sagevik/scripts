#!/bin/sh

# Map scratchpad prefixes to keybindings
get_scratchpad_key() {
  case "$1" in
    ScratchA)
      echo "Super+Shift+a"
      ;;
    ScratchS)
      echo "Super+Shift+s"
      ;;
    ScratchD)
      echo "Super+Shift+d"
      ;;
    ScratchF)
      echo "Super+Shift+f"
      ;;
    ScratchV|"Volume Control"|Pavucontrol)
      echo "Super+Shift+v"
      ;;
    Bitwarden|bitwarden)
      echo "Super+Shift+a"
      ;;
    *)
      echo ""
      ;;
  esac
}

choices=$(
  wmctrl -lx | while IFS= read -r line; do
    # Extract window ID and WM_CLASS
    win_id=$(echo "$line" | awk '{print $1}')
    wm_class=$(echo "$line" | awk '{print $3}')
    title=$(echo "$line" | cut -d' ' -f5- | sed 's/^ *//' | sed 's/^p1 *//')
    # Extract just the class part (after last dot)
    class_name="${wm_class##*.}"

    # Display format
    display="${title}  (${class_name})"
    echo "$display ; $win_id ; $wm_class"
  done
)

selection=$(printf "%s\n" "$choices" | cut -d';' -f1 | sed 's/^\(.\{1,50\}\).*/\1/' | dmenu -fn "Hack:size=16" -i -c -l 15 -p "Select window:")
# echo "selection: $selection"

if [ -n "$selection" ]; then
  line=$(printf "%s\n" "$choices" | grep -F "$selection")
  # echo "line: $line"
  win_id=$(echo "$line" | sed -n 's/.*\(0x[0-9a-fA-F]\+\).*/\1/p')
  # echo "win_id: $win_id"
  wm_class_full=$(echo "$line" | cut -d';' -f3 | xargs)
  # echo "wm_class_full: $wm_class_full"

  # Match known scratchpad prefixes
  scratchpad_prefix=$(echo "$wm_class_full" | grep -oE 'Scratch[ASDFV]|Bitwarden|"Volume Control"|Pavucontrol')

  keybinding=$(get_scratchpad_key "$scratchpad_prefix")

  if [ -n "$keybinding" ]; then
    xdotool key "$keybinding"
  else
    wmctrl -ia "$win_id"
    xdotool windowactivate "$win_id"
  fi
fi

