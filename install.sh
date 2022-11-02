#!/bin/sh

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

#TODO: Verify that we have elevated permissions

# Run all install scripts in series.
# This loop will not work if the absolute path of THIS script contains spaces
for script in $(dirname "$0")/scripts/*.sh; do
    echo ""
    echo "${COLOR_STARTING}***** Running '$script'...$COLOR_STOP"
    bash "$script"

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

SHELL_RC_PATH="/home/$SUDO_USER/.bashrc"
echo ""
echo "You should now restart your terminal session so that the new aliases in '$SHELL_RC_PATH' take effect."
echo ""

exit 0
