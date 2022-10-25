#!/bin/sh

echo "Setting up Dan's bash dotfiles..."

shellRcPath=/home/$SUDO_USER/.bashrc

aliasRcComment="Auto-added aliases from Dan's dotfiles repo"
lineCount=$(grep "$aliasRcComment" "$shellRcPath" | wc --lines)
if [ $lineCount -gt 0 ]; then
    echo "Shell shortcut aliases already set"
    exit 0
fi

echo "Setting shell shortcut aliases..."

(cat <<EOF

# $aliasRcComment

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
) >> "$shellRcPath"
