#! /bin/sh

# Symlink all scripts to /usr/local/bin

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TARGET="/usr/local/bin"

RED="\033[1;31m"
GREEN="\033[1;32m"
NC="\033[0m"

for bin in $(ls "$SCRIPT_DIR")
do
	case $bin in
		"install.sh") continue;;
		"README") continue;;
	esac
	[ ! -L "$TARGET/$bin" ] && sudo ln -sf $SCRIPT_DIR/$bin $TARGET  \
		&& echo -e "Symlink for $bin -> ${RED}created${NC}" \
		|| echo -e "Symlink for $bin -> ${GREEN}OK${NC}"
done

