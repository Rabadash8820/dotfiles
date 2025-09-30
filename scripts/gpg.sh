#!/bin/sh

# Load environment variables from provided configuration file
. "$(dirname "$0")/../scripts/util/validate-config.sh"
ADD_RC_COMMANDS_SCRIPT=$(grep ADD_RC_COMMANDS_SCRIPT "$cfgFilePath" | cut -d '=' -f 2)
SHELL_RC_FILE=$(grep SHELL_RC_FILE "$cfgFilePath" | cut -d '=' -f 2)
MACHINE_TYPE=$(grep MACHINE_TYPE "$cfgFilePath" | cut -d '=' -f 2)
HOME_DIR=$(grep HOME_DIR "$cfgFilePath" | cut -d '=' -f 2)
USER_EMAIL=$(grep USER_EMAIL "$cfgFilePath" | cut -d '=' -f 2)

echo "Setting up GPG for a '$MACHINE_TYPE' machine..."

# Ensure GPG is installed
gpgVersion=$(gpg --version)
if [ -z "$gitVersion" ] ; then
    echo "Installing gpg..."
    apt-get install gpg gnupg2 pinentry-tty --yes
fi

gpgAgentConfPath=$HOME_DIR/.gnupg/gpg-agent.conf
sudo -u $SUDO_USER touch "$gpgAgentConfPath"
grep pinentry-program "$gpgAgentConfPath" > /dev/null
if [ $? = 0 ]; then
    echo "GPG pinentry-program already set"
else
    echo "Setting GPG pinentry-program to Gpg4win..."
    echo "# Use Gpg4win in host Windows OS for pin entry" >> "$gpgAgentConfPath"
    echo "pinentry-program \"/usr/bin/pinentry-tty\"" >> "$gpgAgentConfPath"
fi

sudo -u $SUDO_USER git config --global user.signingkey > /dev/null
if [ $? = 0 ]; then
    echo "Global git user.signingkey already set"
else
    echo "Setting global git user.signingkey to key matching user email (\'$USER_EMAIL\')..."
    # Extract signing subkey from key matching user email
    gpgSigningKeyID=$(sudo -u $SUDO_USER gpg --list-keys --with-colons "$USER_EMAIL" | grep :s: | cut -d ':' -f 5)
    sudo -u $SUDO_USER git config --global user.signingkey "$gpgSigningKeyID"
fi

(cat <<EOF
alias gpgb="gpg --detach-sign"
alias gpgc="gpg --symmetric"
alias gpge="gpg --encrypt"
alias gpgd="gpg --decrypt"
alias gpgh="gpg --help"
alias gpgk="gpg --list-keys --keyid-format=long"
alias gpgs="gpg --sign"

export GPG_TTY=\$(tty)
EOF
) | "$ADD_RC_COMMANDS_SCRIPT" "$SHELL_RC_FILE" "gpg"
