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

for script in scripts/*.sh; do
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

exit 0
