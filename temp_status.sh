#!/bin/sh

TMPFILE="/tmp/tempstatus"

# Ensure the tempfile exists
[ -f "$TMPFILE" ] || echo "" > "$TMPFILE"

update_status() {
    pkill -RTMIN+5 slstatus
}

add_tempinfo() {
    # Add statusbar info only if it's not already present
    if ! grep -o "$1" "$TMPFILE" > /dev/null; then
        if [ -s "$TMPFILE" ]; then
            echo "$(cat "$TMPFILE") $1" > "$TMPFILE"
        else
            echo "$1" > "$TMPFILE"
        fi
    fi
}

remove_tempinfo() {
    # Remove the specific info and clean up extra spaces
    sed -i -e "s/$1//g" -e 's/  */ /g' -e 's/^ //' -e 's/ $//' "$TMPFILE"
}

