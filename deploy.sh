#!/bin/sh
# Copies the addon into the game's AddOns folder so it can be tried in game.
#
# Set WOW_ADDONS_DIR to the game's Interface/AddOns folder, either in the environment or in
# a .deploy.env file next to this script (it's git-ignored), for example:
#   WOW_ADDONS_DIR="/mnt/c/Games/World of Warcraft 3.3.5a/Interface/AddOns"
#
# After deploying, /reload in game is enough, unless files were added to or removed from
# QuietChat.toc: then restart the game completely.
set -eu
cd "$(dirname "$0")"

if [ -f .deploy.env ]; then
	. ./.deploy.env
fi
: "${WOW_ADDONS_DIR:?Set WOW_ADDONS_DIR to the game's Interface/AddOns folder (see deploy.sh)}"
if [ ! -d "$WOW_ADDONS_DIR" ]; then
	echo "Not a folder: $WOW_ADDONS_DIR" >&2
	exit 1
fi

target="$WOW_ADDONS_DIR/QuietChat"
mkdir -p "$target"
# Only the files the game loads; --delete removes files that no longer exist here
rsync -rt --delete --include='/QuietChat.toc' --include='/*.lua' --include='/libs/***' --exclude='*' ./ "$target/"
echo "Deployed to $target"
