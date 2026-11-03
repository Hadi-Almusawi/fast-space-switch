cask "fast-space-switch" do
  version "1.2.0"
  sha256 "74178963c45d0d5f57898f3f383cbf8c56e8fcef65a053fcc4ba3118555f76b3"

  url "https://github.com/Hadi-Almusawi/fast-space-switch/releases/download/v#{version}/FastSpaceSwitch-#{version}.zip"
  name "FastSpaceSwitch"
  desc "Instant Ctrl+Left/Right switching between macOS Spaces"
  homepage "https://hadi-almusawi.github.io/fast-space-switch/"

  depends_on macos: :tahoe

  installer script: {
    executable: "#{staged_path}/FastSpaceSwitch-#{version}/install.sh",
    args:       ["--prebuilt"],
    sudo:       false,
  }

  uninstall script: {
    executable: "#{staged_path}/FastSpaceSwitch-#{version}/uninstall.sh",
    sudo:       false,
  }

  caveats <<~EOS
    This release is for macOS Tahoe 26. macOS 27 is not supported.
    Allow FastSpaceSwitch in System Settings > Privacy & Security > Accessibility for Ctrl+Left/Right.
    The app is installed in ~/Applications and opens at login.
    Installation turns off the two built-in Ctrl+Arrow Space shortcuts.
    Install sets the Dock's window-view animation time to zero.
    Uninstalling restores the shortcuts and your old Dock setting. The app is not notarized by Apple.
  EOS
end
