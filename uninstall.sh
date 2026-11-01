#!/bin/zsh
# Stops FastSpaceSwitch, removes it, and gives Ctrl+Left/Right back to macOS.
cd "$(dirname "$0")"
DOCK_BACKUP_DIR="$HOME/Library/Application Support/FastSpaceSwitch"
DOCK_BACKUP="$DOCK_BACKUP_DIR/dock-animation"

pkill -x FastSpaceSwitch 2>/dev/null
tccutil reset Accessibility local.hadi.fastspaceswitch 2>/dev/null
rm -rf FastSpaceSwitch.app

# Restore macOS's own "Move left/right a space" shortcuts
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 '<dict><key>enabled</key><true/></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 '<dict><key>enabled</key><true/></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

if [[ -f "$DOCK_BACKUP" ]]; then
  old_duration="$(cat "$DOCK_BACKUP")"
  if [[ "$old_duration" == "unset" ]]; then
    defaults delete com.apple.dock expose-animation-duration 2>/dev/null || true
  else
    defaults write com.apple.dock expose-animation-duration -float "$old_duration"
  fi
  rm "$DOCK_BACKUP"
  rmdir "$DOCK_BACKUP_DIR" 2>/dev/null || true
  killall Dock 2>/dev/null || true
fi

echo "Uninstalled. Ctrl+Left/Right and the Dock animation setting are restored."
