#! /bin/sh

# Symlink or remove symlinks for scripts in /usr/local/bin

SCRIPT_DIR=$( cd -- "$( dirname -- "${0}" )" && pwd )
TARGET="/usr/local/bin"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m"

msg() {
    msg=" $1 "
    color_var="${2:-GREEN}"
    color=$(eval echo "\$$color_var")

    border=$(echo "$msg" | sed 's/./-/g')
    echo -e "$CYAN$border"
    echo -e "$color$msg"
    echo -e "$CYAN$border$NC"
}

list_scripts() {
    ls "$SCRIPT_DIR" | grep -Ev "install.sh|README|temp_status.sh|autostart.sh|\.tmp$"
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

msg "Scripts installation"
echo "What do you want to do?"
echo -e "${GREEN}1. Install scripts"
echo -e "${RED}2. Uninstall scripts${NC}"
read -p "Choose an option (1 or 2): " choice
# echo -e "$NC"

if [ "$choice" = "1" ]; then
    echo ""
    msg "Install mode:"
    echo -e "${RED}1. All scripts"
    echo -e "${GREEN}2. Select scripts${NC}"
    read -p "Choose an option (1 or 2): " mode
    case "$mode" in
        1) process_scripts install_script "all" ;;
        2) process_scripts install_script "select" ;;
        *) echo -e "${RED}Invalid option. Exiting.${NC}" ;;
    esac
elif [ "$choice" = "2" ]; then
    echo ""
    msg "Uninstall mode:"
    echo -e "${RED}1. All scripts"
    echo -e  "${GREEN}2. Select scripts${NC}"
    read -p "Choose an option (1 or 2): " mode
    case "$mode" in
        1) process_scripts uninstall_script "all" ;;
        2) process_scripts uninstall_script "select" ;;
        *) echo -e "${RED}Invalid option. Exiting.${NC}" ;;
    esac
else
    echo -e "${RED}Invalid option. Exiting.${NC}"
fi

