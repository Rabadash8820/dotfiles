#!/bin/sh

# Load environment variables from provided configuration file
. "$(dirname "$0")/../scripts/util/validate-config.sh"
ADD_RC_COMMANDS_SCRIPT=$(grep ADD_RC_COMMANDS_SCRIPT "$cfgFilePath" | cut -d '=' -f 2)
SHELL_RC_FILE=$(grep SHELL_RC_FILE "$cfgFilePath" | cut -d '=' -f 2)

echo "Setting up Dan's bash dotfiles..."

(cat <<EOF
alias cpr="cp --recursive"

alias lsa="ls --all"
alias lsal="ls --all -l"
alias lsl="ls -l"
alias lslr="ls -l --recursive"
alias lsr="ls --recursive"

alias rmfr="rm --force --recursive"

alias src="source ~/.bashrc"
alias virc="vim ~/.bashrc"

alias wcb="wcb --bytes"
alias wcl="wc --lines"
alias wcm="wcm --chars"
alias wcm="wcw --words"
EOF
) | "$ADD_RC_COMMANDS_SCRIPT" "$SHELL_RC_FILE" "bash"
