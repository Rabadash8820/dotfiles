#!/bin/sh

# Load environment variables from provided configuration file
. "$(dirname "$0")/../scripts/util/validate-config.sh"
ADD_ALIASES_SCRIPT=$(grep ADD_ALIASES_SCRIPT "$cfgFilePath" | cut -d '=' -f 2)
HOME_DIR=$(grep HOME_DIR "$cfgFilePath" | cut -d '=' -f 2)
REPOS_FOLDER=$(grep REPOS_FOLDER "$cfgFilePath" | cut -d '=' -f 2)
SHELL_RC_FILE=$(grep SHELL_RC_FILE "$cfgFilePath" | cut -d '=' -f 2)

echo "Setting up Dan's git dotfiles..."

# Verify git is installed
gitVersion=$(git --version)
if [ -z "$gitVersion" ] ; then
    echo "Install git and make sure its available on your PATH, then run this script again."
    exit 1
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

# Save git-related shell aliases
(cat <<EOF
alias g=git
EOF
) | "$ADD_ALIASES_SCRIPT" "$SHELL_RC_FILE" "git"
