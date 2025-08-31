#!/usr/bin/env bash

if [[ -z "$TMUX" ]]; then
    notify-send "cht.sh" "Will only run in a tmux session"
    exit 0
fi

FZF_OPTS="--tmux center,50%,40%,border-native --layout=reverse --no-preview"
selected=`cat ~/.config/tmux/tmux-cht-languages ~/.config/tmux/tmux-cht-command | fzf $FZF_OPTS`
if [[ -z $selected ]]; then
    exit 0
fi

FZF_OPTS="--tmux center,50%,5%,border-native --layout=reverse --no-preview"
query=$(echo | fzf $FZF_OPTS --prompt "$selected -> Enter Query: " --print-query | tail -n1)
if [[ -z $query ]]; then
    exit 0
fi

if grep -qs "$selected" ~/.config/tmux/tmux-cht-languages; then
    query=$(echo $query | tr ' ' '+')
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & sleep infinity"
else
    tmux neww bash -c "curl -s cht.sh/$selected~$query & sleep infinity"
fi
