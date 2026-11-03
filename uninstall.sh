#!/bin/zsh
# Stops FastSpaceSwitch, removes it, and gives Ctrl+Left/Right back to macOS.
set -euo pipefail
INSTALLED_APP="$HOME/Applications/FastSpaceSwitch.app"
DOCK_BACKUP_DIR="$HOME/Library/Application Support/FastSpaceSwitch"
DOCK_BACKUP="$DOCK_BACKUP_DIR/dock-animation"
HOTKEY_BACKUP="$DOCK_BACKUP_DIR/space-shortcuts.plist"
UNINSTALLER="$DOCK_BACKUP_DIR/uninstall.sh"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/local.hadi.fastspaceswitch.plist"

restore_space_shortcuts() {
  if [[ -f "$HOTKEY_BACKUP" ]]; then
    plutil -lint -s "$HOTKEY_BACKUP"
    local current="$(mktemp "$DOCK_BACKUP_DIR/current-hotkeys.XXXXXX")"
    defaults export com.apple.symbolichotkeys "$current"
    if ! plutil -type AppleSymbolicHotKeys "$current" >/dev/null 2>&1; then
      plutil -insert AppleSymbolicHotKeys -dictionary "$current"
    fi
    local key original
    for key in 79 81; do
      if original="$(plutil -extract "AppleSymbolicHotKeys.$key" json -o - "$HOTKEY_BACKUP" 2>/dev/null)"; then
        if plutil -type "AppleSymbolicHotKeys.$key" "$current" >/dev/null 2>&1; then
          plutil -replace "AppleSymbolicHotKeys.$key" -json "$original" "$current"
        else
          plutil -insert "AppleSymbolicHotKeys.$key" -json "$original" "$current"
        fi
      else
        plutil -remove "AppleSymbolicHotKeys.$key" "$current" 2>/dev/null || true
      fi
    done
    defaults import com.apple.symbolichotkeys "$current"
    rm "$current"
  else
    # Older installations had no shortcut backup. Restore standard shortcuts.
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 \
      '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>123</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 \
      '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>124</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>'
  fi
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
}

if [[ -e "$INSTALLED_APP" ]]; then
  installed_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INSTALLED_APP/Contents/Info.plist" 2>/dev/null || true)"
  [[ "$installed_id" == "local.hadi.fastspaceswitch" ]] || { echo "$INSTALLED_APP belongs to another app. Removal stopped." >&2; exit 1; }
fi

restore_space_shortcuts
if [[ -f "$LAUNCH_AGENT" ]]; then
  agent_label="$(/usr/libexec/PlistBuddy -c 'Print :Label' "$LAUNCH_AGENT" 2>/dev/null || true)"
  if [[ "$agent_label" == "local.hadi.fastspaceswitch" ]]; then
    launchctl bootout "gui/$(id -u)/local.hadi.fastspaceswitch" 2>/dev/null || true
    rm "$LAUNCH_AGENT"
  else
    echo "Skipped an unrelated login item at $LAUNCH_AGENT." >&2
  fi
fi
pkill -x FastSpaceSwitch 2>/dev/null || true
tccutil reset Accessibility local.hadi.fastspaceswitch 2>/dev/null || true
[[ ! -e "$INSTALLED_APP" ]] || rm -rf "$INSTALLED_APP"

if [[ -f "$DOCK_BACKUP" ]]; then
  old_duration="$(cat "$DOCK_BACKUP")"
  if [[ "$old_duration" == "unset" ]]; then
    defaults delete com.apple.dock expose-animation-duration 2>/dev/null || true
  else
    defaults write com.apple.dock expose-animation-duration -float "$old_duration"
  fi
  rm "$DOCK_BACKUP"
  killall Dock 2>/dev/null || true
fi
[[ ! -f "$HOTKEY_BACKUP" ]] || rm "$HOTKEY_BACKUP"
[[ ! -f "$UNINSTALLER" ]] || rm "$UNINSTALLER"
rmdir "$DOCK_BACKUP_DIR" 2>/dev/null || true

echo "Uninstalled. Your previous Ctrl+Left/Right and Dock settings are restored."
