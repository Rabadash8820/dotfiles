#!/bin/sh

shellRcPath=$1
name=$2

if [ ! -f "$shellRcPath" ]; then
    echo "Shell rc file does not exist at '$shellRcPath'. Creating it now..."
    sudo -u $SUDO_USER touch "$shellRcPath"
fi

rcComment="Auto-added $name commands from Dan's dotfiles repo"

grep "$rcComment" "$shellRcPath" > /dev/null
if [ $? = 0 ]; then
    echo "$name commands already added to '$shellRcPath'"
    exit 0
fi

echo "Adding $name commands to '$shellRcPath'..."

(cat <<EOF

# $rcComment

EOF
) >> "$shellRcPath"
cat >> "$shellRcPath"
