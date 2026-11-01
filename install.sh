#!/bin/zsh
# Builds FastSpaceSwitch.app, hands Ctrl+Left/Right to it, and starts it.
set -euo pipefail
cd "$(dirname "$0")"

APP="$PWD/FastSpaceSwitch.app"
DOCK_BACKUP="$PWD/.fastspaceswitch-dock-animation"

# Build, or use the app included in a release download.
if [[ "${1:-}" != "" && "${1:-}" != "--prebuilt" ]]; then
  echo "Usage: ./install.sh [--prebuilt]" >&2
  exit 1
fi
if [[ "${1:-}" == "--prebuilt" ]]; then
  [[ -x "$APP/Contents/MacOS/FastSpaceSwitch" ]] || { echo "The release app is missing. Run ./install.sh to build it." >&2; exit 1; }
  codesign --verify --deep --strict "$APP"
fi
pkill -x FastSpaceSwitch 2>/dev/null || true
if [[ "${1:-}" != "--prebuilt" ]]; then
  rm -rf "$APP"
  mkdir -p "$APP/Contents/MacOS"
  cp Info.plist "$APP/Contents/Info.plist"
  clang -O2 -Wall -o "$APP/Contents/MacOS/FastSpaceSwitch" main.m \
    -framework Cocoa -framework ApplicationServices -framework Carbon
  codesign --force --sign - "$APP"
fi

# Turn off macOS's own "Move left/right a space" (79/81) so Ctrl+Arrow reaches us
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>123</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>124</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Ctrl+Up/Down stay macOS shortcuts. Remove the Dock's Exposé animation.
# Save the user's old setting so uninstall can put it back.
if [[ ! -f "$DOCK_BACKUP" ]]; then
  if old_duration="$(defaults read com.apple.dock expose-animation-duration 2>/dev/null)"; then
    print -r -- "$old_duration" > "$DOCK_BACKUP"
  else
    print -r -- "unset" > "$DOCK_BACKUP"
  fi
fi
defaults write com.apple.dock expose-animation-duration -float 0
killall Dock 2>/dev/null || true

open "$APP"
echo "Installed. Ctrl+Up/Down use macOS's window views with the Dock animation set to zero."
echo "Turn on FastSpaceSwitch in System Settings > Privacy & Security > Accessibility for Ctrl+Left/Right."
