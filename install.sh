#!/bin/sh

# Restart as root user
# Inspired by https://stackoverflow.com/questions/71622881/how-can-i-request-elevated-permissions-in-a-bash-scripts-begin-and-let-it-go-at
# and https://hugomartins.io/essays/2017/03/elevate-shell-scripts/
# https://www.petefreitag.com/blog/environment-variables-sudo/
if [ -z "$SUDO_USER" ]; then
    echo "Elevating install script..."
    sudo SUDO_HOME=$HOME "$0" "$@"
    exit $?
else
    echo "Install script already elevated (SUDO_USER: $SUDO_USER)"
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

echo ""
echo "***************************"
echo "DAN'S DOTFILES ARE BEGIN!!!"
echo "***************************"
echo ""

# Generate temporary shared configuration file for all install scripts
currDir=$(dirname "$0")
homeDir=$SUDO_HOME
cfgFilePath=$homeDir/dotfiles/.env
echo "Generating temporary shared configuration file at '$cfgFilePath'..."
reposFolder=${DOTFILES_REPOS_FOLDER:-$homeDir/repos}
(cat <<EOF
ADD_ALIASES_SCRIPT=$currDir/scripts/util/add-aliases.sh
HOME_DIR=${DOTFILES_HOME_DIR:-$homeDir}
SHELL_RC_FILE=${DOTFILES_SHELL_RC_FILE:-$homeDir/.bashrc}
REPOS_FOLDER=$reposFolder
USER_NAME=${DOTFILES_USER_NAME:-Dan Vicarel}
EOF
) > "$cfgFilePath"


echo "Creating folder where helper repos will be cloned with the right permissions"
mkdir --parents "$reposFolder"
chown --recursive $SUDO_USER "$reposFolder"

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

SHELL_RC_FILE="/$homeDir/.bashrc"
echo ""
echo "You should now restart your terminal session so that the new aliases in '$SHELL_RC_FILE' take effect."
echo ""

exit 0
