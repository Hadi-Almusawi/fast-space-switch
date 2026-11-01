cask "fast-space-switch" do
  version "1.1.0"
  sha256 "92003d0fe38fbe6f46fd9f41db35de023c6b07300e09797cb05efd8bede8262c"

  url "https://github.com/Hadi-Almusawi/fast-space-switch/releases/download/v#{version}/FastSpaceSwitch-#{version}.zip"
  name "FastSpaceSwitch"
  desc "Instant Ctrl+Arrow switching between macOS Spaces without animation"
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
    The app runs from its Homebrew folder, not /Applications.
    Installation turns off the two built-in Ctrl+Arrow Space shortcuts.
    Ctrl+Up/Down stay macOS shortcuts. Install sets the Dock's window-view animation time to zero.
    Uninstalling restores the shortcuts and your old Dock setting. The app is not notarized by Apple.
  EOS
end
