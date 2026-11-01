cask "fast-space-switch" do
  version "1.0.0"
  sha256 "89049ae228cbbe378cb6bf0ce2576fdb7b0966b83ca4d35103b0fb6b8078539a"

  url "https://github.com/Hadi-Almusawi/fast-space-switch/releases/download/v#{version}/FastSpaceSwitch-#{version}.zip"
  name "FastSpaceSwitch"
  desc "Instant Ctrl+Arrow switching between macOS Spaces without animation"
  homepage "https://hadi-almusawi.github.io/fast-space-switch/"

  depends_on macos: ">= :tahoe"

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
    Allow FastSpaceSwitch in System Settings > Privacy & Security > Accessibility.
    The app runs from its Homebrew folder, not /Applications.
    Installation turns off the two built-in Ctrl+Arrow Space shortcuts.
    Uninstalling restores those shortcuts. The app is not notarized by Apple.
  EOS
end
