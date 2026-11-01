#!/bin/zsh
# Build a universal release without changing shortcuts or launching the app.
set -euo pipefail
cd "$(dirname "$0")/.."
RELEASE_DIR="$(mktemp -d /private/tmp/fastspaceswitch-release.XXXXXX)"
PACKAGE="$RELEASE_DIR/FastSpaceSwitch-1.1.1"
APP="$PACKAGE/FastSpaceSwitch.app"
mkdir -p "$APP/Contents/MacOS"
cp Info.plist "$APP/Contents/Info.plist"
clang -O2 -Wall -Wextra -arch arm64 -arch x86_64 -mmacosx-version-min=26.0 \
  -o "$APP/Contents/MacOS/FastSpaceSwitch" main.m \
  -framework Cocoa -framework ApplicationServices -framework Carbon
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"
cp README.md LICENSE main.m Info.plist install.sh uninstall.sh "$PACKAGE/"
chmod +x "$PACKAGE/install.sh" "$PACKAGE/uninstall.sh"
ditto -c -k --sequesterRsrc --keepParent "$PACKAGE" "$RELEASE_DIR/FastSpaceSwitch-1.1.1.zip"
shasum -a 256 "$RELEASE_DIR/FastSpaceSwitch-1.1.1.zip"
echo "Release: $RELEASE_DIR/FastSpaceSwitch-1.1.1.zip"
