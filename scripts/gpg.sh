#!/bin/sh

# Load environment variables from provided configuration file
. "$(dirname "$0")/../scripts/util/validate-config.sh"
ADD_RC_COMMANDS_SCRIPT=$(grep ADD_RC_COMMANDS_SCRIPT "$cfgFilePath" | cut -d '=' -f 2)
SHELL_RC_FILE=$(grep SHELL_RC_FILE "$cfgFilePath" | cut -d '=' -f 2)
MACHINE_TYPE=$(grep MACHINE_TYPE "$cfgFilePath" | cut -d '=' -f 2)
HOME_DIR=$(grep HOME_DIR "$cfgFilePath" | cut -d '=' -f 2)

echo "Setting up GPG for a '$MACHINE_TYPE' machine..."

# Verify GPG is installed
gpgVersion=$(gpg --version)
if [ -z "$gpgVersion" ] ; then
    echo "Install gpg and make sure its available on your PATH, then run this script again."
    exit 1
fi

if [ "$MACHINE_TYPE" = "$MACHINE_TYPE_WSL" ]; then
    sudo -u $SUDO_USER touch "$HOME_DIR/gpg-agent.conf"
    grep pinentry-program "$HOME_DIR/gpg-agent.conf" > /dev/null
    if [ $? = 0 ]; then
        echo "GPG pinentry-program already set"
    else
        echo "Setting GPG pinentry-program to Gpg4win..."
        echo "# Use Gpg4win in host Windows OS for pin entry" >> "$HOME_DIR/gpg-agent.conf"
        echo "pinentry-program /mnt/c/Program Files (x86)/Gpg4win/bin/pinentry.exe" >> "$HOME_DIR/gpg-agent.conf"
    fi
fi

(cat <<EOF
alias gpgb="gpg --detach-sign"
alias gpgc="gpg --symmetric"
alias gpge="gpg --encrypt"
alias gpgd="gpg --decrypt"
alias gpgh="gpg --help"
alias gpgk="gpg --list-keys"
alias gpgs="gpg --sign"
EOF
) | "$ADD_RC_COMMANDS_SCRIPT" "$SHELL_RC_FILE" "gpg"
