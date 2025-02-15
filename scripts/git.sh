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
    branch=$(git -C "$gitAliasPath" rev-parse --abbrev-ref HEAD)
    modifiedFileCount=$(git -C "$gitAliasPath" status --short | grep "^ M *" | wc --lines)
    if [ "$branch" = "main" -a "$modifiedFileCount" = "0" ]; then
        echo "Pulling latest changes to '$gitAliasRepoName' repo..."
        git -C "$gitAliasPath" pull
        #TODO: git pull
    else
        echo -e "${COLOR_WARNING}Could not update '$gitAliasRepoName' repo. Branch is not 'main' or there are uncommitted file modifications...$COLOR_STOP"
    fi
else
    gitAliasRepoUrl=https://github.com/Rabadash8820/$gitAliasRepoName
    echo "Cloning repo '$gitAliasRepoUrl' into '$gitAliasPath'..."
    mkdir --parents "$gitAliasPath"
    git clone $gitAliasRepoUrl "$gitAliasPath"
    chown --recursive $SUDO_USER:$SUDO_USER "$gitAliasPath"
    git -C "$gitAliasPath" lfs install
    git -C "$gitAliasPath" lfs pull
fi

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

# TODO: update Git to at least v2.45.0 so we can use `git config --comment` option (see https://github.com/git/git/blob/master/Documentation/RelNotes/2.45.0.txt#L69)
# Mainly for Debian-based devcontainers...
# Latest stable Debian (bookworm) only goes up to git 2.41.0, and the bookworm-backports apt repository doesn't have higher either.
# Don't forget to add Danovo WSL GPG key to GitHub...

# Set other git configs (for correct non-root user)
echo "Setting other global git configs..."
function setGitConfigIfEmpty() {
    sudo -u $SUDO_USER git config --global "$1" > /dev/null
    if [ $? -gt 0 ]; then
        sudo -u $SUDO_USER git config --global "$1" "$2"
    fi
}
setGitConfigIfEmpty "user.name" "$USER_NAME"
setGitConfigIfEmpty "user.email" "$USER_EMAIL"
setGitConfigIfEmpty "user.signingkey" "TODO"
sudo -u $SUDO_USER git config --global user.useconfigonly true  # Require committer name/email to be set in config, not guessed by git
sudo -u $SUDO_USER git config --global commit.gpgsign true
sudo -u $SUDO_USER git config --global tag.gpgsign true
echo -e "${COLOR_WARNING}Set user.signingkey in your global git config to your desired GPG key ID$COLOR_STOP"

# Save git-related shell aliases
(cat <<EOF
alias g=git
EOF
) | "$ADD_RC_COMMANDS_SCRIPT" "$SHELL_RC_FILE" "git"
