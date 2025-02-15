#!/bin/sh

# Load environment variables from provided configuration file
. "$(dirname "$0")/../scripts/util/validate-config.sh"
ADD_RC_COMMANDS_SCRIPT=$(grep ADD_RC_COMMANDS_SCRIPT "$cfgFilePath" | cut -d '=' -f 2)
HOME_DIR=$(grep HOME_DIR "$cfgFilePath" | cut -d '=' -f 2)
REPOS_FOLDER=$(grep REPOS_FOLDER "$cfgFilePath" | cut -d '=' -f 2)
SHELL_RC_FILE=$(grep SHELL_RC_FILE "$cfgFilePath" | cut -d '=' -f 2)
USER_NAME=$(grep USER_NAME "$cfgFilePath" | cut -d '=' -f 2)
USER_EMAIL=$(grep USER_EMAIL "$cfgFilePath" | cut -d '=' -f 2)

echo "Setting up Dan's git dotfiles..."

# TODO: update Git to latest stable version so we have all subcommands/options

# Ensure git is installed
gitVersion=$(git --version)
if [ -z "$gitVersion" ] ; then
    echo "Installing git..."
    apt-get install git
fi
gitLfsVersion=$(git lfs --version)
if [ -z "$gitLfsVersion" ] ; then
    echo "Installing git LFS..."
    apt-get install git-lfs
fi

# Clone git aliases repo, if necessary
gitAliasRepoName=GitAliases
gitAliasPath=$REPOS_FOLDER/$gitAliasRepoName
if [ -d "$gitAliasPath" ] ; then
    echo "'$gitAliasRepoName' repo already cloned"
else
    gitAliasRepoUrl=https://github.com/Rabadash8820/$gitAliasRepoName
    echo "Cloning repo '$gitAliasRepoUrl' into '$gitAliasPath'..."
    mkdir --parents "$gitAliasPath"
    git clone $gitAliasRepoUrl "$gitAliasPath"
    chown --recursive $SUDO_USER:$SUDO_USER "$gitAliasPath"
fi

#TODO: Check if git aliases repo is up-to-date (in background on repeat?)

# [include] git aliases from repo, if necessary
globalGitConfigPath=$HOME_DIR/.gitconfig
lineCount=$(grep $gitAliasRepoName "$globalGitConfigPath" | wc --lines)
if [ $lineCount -gt 0 ] ; then
    echo "Git aliases in '$gitAliasRepoName' repo have already been [include]d in global git config at '$globalGitConfigPath'"
else
    echo "[include]ing shortcut and extension aliases from '$gitAliasRepoName' in global git config at '$globalGitConfigPath'"
    (cat <<EOF

[include]
    path = $gitAliasPath/shortcut-aliases/.gitconfig
    path = $gitAliasPath/extension-aliases/.gitconfig
EOF
    ) >> "$globalGitConfigPath"
fi

# Set other git configs (for correct non-root user)
echo "Setting other global git configs..."
function trySetGitConfig() {
    sudo -u $SUDO_USER git config --global "$1" > /dev/null
    if [ $? -gt 0 ]; then
        sudo -u $SUDO_USER git config --global --comment "$3" "$1" "$2"
    fi
}
trySetGitConfig "user.name" "$USER_NAME"
trySetGitConfig "user.email" "$USER_EMAIL"
trySetGitConfig "user.signingkey" "TODO"
sudo -u $SUDO_USER git config --global --comment "Require committer name/email to be set in config, not guessed by git" user.useconfigonly true
sudo -u $SUDO_USER git config --global commit.gpgsign true
sudo -u $SUDO_USER git config --global tag.gpgsign true
echo "${COLOR_WARNING}Set user.signingkey in your global git config to your desired GPG key ID$COLOR_STOP"

# Save git-related shell aliases
(cat <<EOF
alias g=git
EOF
) | "$ADD_RC_COMMANDS_SCRIPT" "$SHELL_RC_FILE" "git"
