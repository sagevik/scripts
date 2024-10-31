#! /bin/sh

# Symlink all scripts to /usr/local/bin

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TARGET="/usr/local/bin"

for bin in $(ls "$SCRIPT_DIR")
do
	case $bin in
		"install.sh") continue;;
		"README") continue;;
	esac
	sudo ln -sf $SCRIPT_DIR/$bin $TARGET
	echo "Symlink for $bin created"
done
