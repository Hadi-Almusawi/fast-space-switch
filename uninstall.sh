#!/bin/zsh
# Stops FastSpaceSwitch, removes it, and gives Ctrl+Left/Right back to macOS.
cd "$(dirname "$0")"

pkill -x FastSpaceSwitch 2>/dev/null
tccutil reset Accessibility local.hadi.fastspaceswitch 2>/dev/null
rm -rf FastSpaceSwitch.app

# Restore macOS's own "Move left/right a space" shortcuts
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 '<dict><key>enabled</key><true/></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 '<dict><key>enabled</key><true/></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

echo "Uninstalled. Ctrl+Left/Right are back to the normal macOS behavior."
