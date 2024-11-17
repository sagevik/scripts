#! /bin/sh

# Symlink or remove symlinks for scripts in /usr/local/bin

SCRIPT_DIR=$( cd -- "$( dirname -- "${0}" )" && pwd )
TARGET="/usr/local/bin"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

list_scripts() {
    ls "$SCRIPT_DIR" | grep -Ev "install.sh|README"
}

list_installed_scripts() {
    list_scripts | while read -r script; do
        [ -L "$TARGET/$script" ] && echo "$script"
    done
}

list_uninstalled_scripts() {
    list_scripts | while read -r script; do
        [ ! -L "$TARGET/$script" ] && echo "$script"
    done
}

install_script() {
    script="$1"
    if [ ! -L "$TARGET/$script" ]; then
        sudo ln -sf "$SCRIPT_DIR/$script" "$TARGET"
        echo -e "Symlink for $script -> ${RED}created${NC}"
    else
        echo -e "Symlink for $script -> ${GREEN}OK${NC}"
    fi
}

uninstall_script() {
    script="$1"
    if [ -L "$TARGET/$script" ]; then
        sudo rm "$TARGET/$script"
        echo -e "Symlink for $script -> ${RED}removed${NC}"
    else
        echo -e "Symlink for $script -> ${YELLOW}not found${NC}"
    fi
}

process_scripts() {
    action="$1"
    mode="$2"

    case "$mode" in
        "all")
            if [ "$action" = "install_script" ]; then
                # Only install uninstalled scripts
                for script in $(list_uninstalled_scripts); do
                    $action "$script"
                done
            elif [ "$action" = "uninstall_script" ]; then
                # Only uninstall installed scripts
                for script in $(list_installed_scripts); do
                    $action "$script"
                done
            fi
            ;;
        "select")
            if [ "$action" = "install_script" ]; then
                available_scripts=$(list_uninstalled_scripts)
                dothis="install"
            elif [ "$action" = "uninstall_script" ]; then
                available_scripts=$(list_installed_scripts)
                dothis="uninstall"
            fi

            if [ -z "$available_scripts" ]; then
                echo "No scripts available for this action."
                return
            fi

            header=$(printf "Select scripts to $dothis\n(up/dn/tab keys to (de)select)")
            selected_scripts=$(echo "$available_scripts" | fzf --multi --prompt="> " --header="$header" --layout=reverse --border=rounded)
            for script in $selected_scripts; do
                $action "$script"
            done
            ;;
    esac
}

echo "What do you want to do?"
echo "1. Install scripts"
echo "2. Uninstall scripts"
read -p "Choose an option (1 or 2): " choice

if [ "$choice" = "1" ]; then
    echo "Install mode:"
    echo "1. All scripts"
    echo "2. Select scripts"
    read -p "Choose an option (1 or 2): " mode
    case "$mode" in
        1) process_scripts install_script "all" ;;
        2) process_scripts install_script "select" ;;
        *) echo "Invalid option. Exiting." ;;
    esac
elif [ "$choice" = "2" ]; then
    echo "Uninstall mode:"
    echo "1. All scripts"
    echo "2. Select scripts"
    read -p "Choose an option (1 or 2): " mode
    case "$mode" in
        1) process_scripts uninstall_script "all" ;;
        2) process_scripts uninstall_script "select" ;;
        *) echo "Invalid option. Exiting." ;;
    esac
else
    echo "Invalid option. Exiting."
fi

