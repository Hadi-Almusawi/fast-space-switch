#!/bin/zsh
# Installs FastSpaceSwitch in the user's Applications folder and starts it.
set -euo pipefail
cd "$(dirname "$0")"

APP="$PWD/FastSpaceSwitch.app"
APPLICATIONS="$HOME/Applications"
INSTALLED_APP="$APPLICATIONS/FastSpaceSwitch.app"
DOCK_BACKUP_DIR="$HOME/Library/Application Support/FastSpaceSwitch"
DOCK_BACKUP="$DOCK_BACKUP_DIR/dock-animation"
HOTKEY_BACKUP="$DOCK_BACKUP_DIR/space-shortcuts.plist"
UNINSTALLER="$DOCK_BACKUP_DIR/uninstall.sh"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/local.hadi.fastspaceswitch.plist"

bundle_id() {
  /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$1/Contents/Info.plist" 2>/dev/null
}

set_window_view_speed() {
  if [[ ! -f "$DOCK_BACKUP" ]]; then
    mkdir -p "$DOCK_BACKUP_DIR"
    if [[ -f "$PWD/.fastspaceswitch-dock-animation" ]]; then
      mv "$PWD/.fastspaceswitch-dock-animation" "$DOCK_BACKUP"
    elif old_duration="$(defaults read com.apple.dock expose-animation-duration 2>/dev/null)"; then
      print -r -- "$old_duration" > "$DOCK_BACKUP"
    else
      print -r -- "unset" > "$DOCK_BACKUP"
    fi
  fi
  defaults write com.apple.dock expose-animation-duration -float 0
  killall Dock 2>/dev/null || true
}

save_space_shortcuts() {
  [[ -f "$HOTKEY_BACKUP" ]] && return
  defaults export com.apple.symbolichotkeys "$HOTKEY_BACKUP"
  plutil -lint -s "$HOTKEY_BACKUP"
  if [[ -f "$DOCK_BACKUP" ]]; then
    # An earlier installer did not save these shortcuts. Their original values
    # cannot be recovered, so use macOS's standard Ctrl+Arrow definitions.
    plutil -replace AppleSymbolicHotKeys.79 -json '{"enabled":true,"value":{"parameters":[65535,123,8650752],"type":"standard"}}' "$HOTKEY_BACKUP"
    plutil -replace AppleSymbolicHotKeys.81 -json '{"enabled":true,"value":{"parameters":[65535,124,8650752],"type":"standard"}}' "$HOTKEY_BACKUP"
  fi
}

prepare_login_agent() {
  mkdir -p "$HOME/Library/LaunchAgents"
  local staged_agent="$STAGING/login-agent.plist"
  plutil -create xml1 "$staged_agent"
  plutil -insert Label -string local.hadi.fastspaceswitch "$staged_agent"
  plutil -insert ProgramArguments -array "$staged_agent"
  plutil -insert ProgramArguments.0 -string "$INSTALLED_APP/Contents/MacOS/FastSpaceSwitch" "$staged_agent"
  plutil -insert RunAtLoad -bool true "$staged_agent"
  plutil -lint -s "$staged_agent"
}

# Build, or use the app included in a release download.
if [[ "${1:-}" != "" && "${1:-}" != "--prebuilt" ]]; then
  echo "Usage: ./install.sh [--prebuilt]" >&2
  exit 1
fi
MACOS_VERSION="$(sw_vers -productVersion)"
if [[ "$MACOS_VERSION" != 26 && "$MACOS_VERSION" != 26.* ]]; then
  echo "FastSpaceSwitch supports macOS Tahoe 26. This Mac is running macOS $MACOS_VERSION. Nothing was installed or changed." >&2
  exit 1
fi
if [[ "${1:-}" == "--prebuilt" ]]; then
  [[ -x "$APP/Contents/MacOS/FastSpaceSwitch" ]] || { echo "The release app is missing. Run ./install.sh to build it." >&2; exit 1; }
  codesign --verify --deep --strict "$APP"
fi
if [[ "${1:-}" != "--prebuilt" ]]; then
  rm -rf "$APP"
  mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
  cp Info.plist "$APP/Contents/Info.plist"
  cp LICENSE "$APP/Contents/Resources/LICENSE"
  clang -O2 -Wall -o "$APP/Contents/MacOS/FastSpaceSwitch" main.m \
    -framework Cocoa -framework ApplicationServices -framework Carbon
  codesign --force --sign - "$APP"
fi
[[ "$(bundle_id "$APP")" == "local.hadi.fastspaceswitch" ]] || { echo "The source app is not FastSpaceSwitch." >&2; exit 1; }
if [[ -e "$INSTALLED_APP" && "$(bundle_id "$INSTALLED_APP")" != "local.hadi.fastspaceswitch" ]]; then
  echo "$INSTALLED_APP belongs to another app. Installation stopped." >&2
  exit 1
fi
if [[ -e "$LAUNCH_AGENT" && "$(/usr/libexec/PlistBuddy -c 'Print :Label' "$LAUNCH_AGENT" 2>/dev/null || true)" != "local.hadi.fastspaceswitch" ]]; then
  echo "$LAUNCH_AGENT belongs to another app. Installation stopped." >&2
  exit 1
fi

mkdir -p "$APPLICATIONS" "$DOCK_BACKUP_DIR"
STAGING="$(mktemp -d "$APPLICATIONS/.FastSpaceSwitch-install.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/FastSpaceSwitch.app"
codesign --verify --deep --strict "$STAGING/FastSpaceSwitch.app"
cp "$PWD/uninstall.sh" "$UNINSTALLER"
chmod +x "$UNINSTALLER"
save_space_shortcuts
prepare_login_agent
pkill -x FastSpaceSwitch 2>/dev/null || true
if [[ -e "$INSTALLED_APP" ]]; then
  mv "$INSTALLED_APP" "$STAGING/previous.app"
fi
if ! mv "$STAGING/FastSpaceSwitch.app" "$INSTALLED_APP"; then
  [[ ! -e "$STAGING/previous.app" ]] || mv "$STAGING/previous.app" "$INSTALLED_APP"
  echo "Could not move FastSpaceSwitch into $APPLICATIONS." >&2
  exit 1
fi
mv "$STAGING/login-agent.plist" "$LAUNCH_AGENT"

# Turn off macOS's own "Move left/right a space" (79/81) so Ctrl+Arrow reaches us
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>123</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>124</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Change the Dock's window-view animation setting.
set_window_view_speed

if open "$INSTALLED_APP"; then
  echo "Installed and opened: $INSTALLED_APP"
else
  echo "Installed in $INSTALLED_APP, but macOS did not open it. Check Privacy & Security for Open Anyway, then open the app from Applications." >&2
fi
echo "The Dock's window-view animation time is set to zero. Uninstall restores your previous setting."
echo "For instant Ctrl+Left/Right, allow FastSpaceSwitch in System Settings > Privacy & Security > Accessibility."
echo "macOS requires this access for the desktop switch gesture. You can now delete the downloaded folder."
echo "FastSpaceSwitch will also open when you log in."
echo "To remove it later, run: zsh \"$UNINSTALLER\""
