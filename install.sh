#!/bin/sh

# Verify that we have elevated permissions
if [ $(id -u) -ne 0 ]; then
    echo "Install scripts must be run with root permissions"
    exit 1
fi

# Set constants
STATUS_SUCCESS=0
STATUS_NON_TERMINAL=1

COLOR_YELLOW="\e[33m"
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_STARTING=$COLOR_YELLOW
COLOR_WARNING=$COLOR_YELLOW
COLOR_ERROR=$COLOR_RED
COLOR_SUCCESS=$COLOR_GREEN
COLOR_STOP="\e[0m"

# Generate temporary shared configuration file for all install scripts
currDir=$(dirname "$0")
homeDir=/home/$SUDO_USER
cfgFilePath=$homeDir/dotfiles/.env
echo "Generating temporary shared configuration file at '$cfgFilePath'..."
(cat <<EOF
ADD_ALIASES_SCRIPT=$currDir/scripts/util/add-aliases.sh
HOME_DIR=${DOTFILES_HOME_DIR:-$homeDir}
SHELL_RC_FILE=${DOTFILES_SHELL_RC_FILE:-$homeDir/.bashrc}
REPOS_FOLDER=${DOTFILES_REPOS_FOLDER:-$homeDir/repos}
EOF
) > "$cfgFilePath"

# Run all install scripts in series.
# This loop will not work if the absolute path of THIS script contains spaces
for script in $currDir/scripts/*.sh; do
    echo ""
    echo "${COLOR_STARTING}***** Running '$script'...$COLOR_STOP"
    bash "$script" "$cfgFilePath"

    status=$?
    echo ""
    if [ "$status" = "$STATUS_SUCCESS" ]; then
        echo "${COLOR_SUCCESS}SUCCESS$COLOR_STOP  Install script '$script' completed successfully"
    elif [ "$status" = "$STATUS_NON_TERMINAL" ]; then
        echo "${COLOR_WARNING}WARNING$COLOR_STOP  Install script '$script' exited with non-terminal error status $STATUS_NON_TERMINAL. Continuing installation..."
    else
        echo "${COLOR_ERROR}ERROR$COLOR_STOP  Install script '$script' exited with terminal status $status. See above logs for more info. Stopping installation."
        exit $status
    fi
done

# Cannot apply new aliases here. :/
# Sourcing the rc file would only add them to _this_ script's process, not the calling shell environment.

echo ""
echo "Removing temporary configuration file at '$cfgFilePath'..."
rm $cfgFilePath

SHELL_RC_FILE="/home/$SUDO_USER/.bashrc"
echo ""
echo "You should now restart your terminal session so that the new aliases in '$SHELL_RC_FILE' take effect."
echo ""

exit 0
