#!/bin/sh

echo "Setting up Dan's bash dotfiles..."

(cat <<EOF
alias lsa="ls --all"
alias lsal="ls --all -l"
alias lsl="ls -l"
alias lslr="ls -l --recursive"
alias lsr="ls --recursive"

alias rmrf="rm --force --recursive"

alias src="source ~/.bashrc"
alias virc="vim ~/.bashrc"

alias wcb="wcb --bytes"
alias wcl="wc --lines"
alias wcm="wcm --chars"
alias wcm="wcw --words"
EOF
) | "$(dirname "$0")/util/add-aliases.sh" "/home/$SUDO_USER/.bashrc" "bash"
