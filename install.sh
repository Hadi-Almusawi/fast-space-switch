#!/bin/zsh
# Builds FastSpaceSwitch.app, hands Ctrl+Left/Right to it, and starts it.
set -euo pipefail
cd "$(dirname "$0")"

APP="$PWD/FastSpaceSwitch.app"

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

open "$APP"
echo "Installed. Turn on FastSpaceSwitch in System Settings > Privacy & Security > Accessibility."
