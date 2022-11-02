#!/bin/sh

shellRcPath=$1
if [ ! -f "$shellRcPath" ]; then
    echo "Shell rc file does not exist at '$shellRcPath'. Creating it now..."
    touch "$shellRcPath"
fi

aliasDesc=$2
aliasRcComment="Auto-added $aliasDesc aliases from Dan's dotfiles repo"

lineCount=$(grep "$aliasRcComment" "$shellRcPath" | wc --lines)
if [ $lineCount -gt 0 ]; then
    echo "$aliasDesc aliases already set"
    exit 0
fi

echo "Setting $aliasDesc shortcut aliases..."

(cat <<EOF

# $aliasRcComment

EOF
) >> "$shellRcPath"
cat >> "$shellRcPath"
