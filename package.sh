#!/bin/sh
# Builds the release zip, dist/QuietChat-<version>.zip, with the version from QuietChat.toc.
#
# The zip holds a single QuietChat folder, because the game only loads an addon whose folder
# name matches its .toc. Inside are the files the game loads, plus the README and license.
set -eu
cd "$(dirname "$0")"

version=$(sed -n 's/^## Version: *//p' QuietChat.toc | tr -d '\r')
: "${version:?No ## Version line in QuietChat.toc}"

stage=dist/stage
rm -rf "$stage"
mkdir -p "$stage/QuietChat"
# The files the game loads (see addon-files.filter), plus README.md and LICENSE
rsync -rt --include='/README.md' --include='/LICENSE' --filter='merge addon-files.filter' \
	./ "$stage/QuietChat/"

zip="QuietChat-$version.zip"
rm -f "dist/$zip"
(cd "$stage" && zip -qr "../$zip" QuietChat)
rm -rf "$stage"
echo "dist/$zip"
