# FastSpaceSwitch

Switch desktops in an instant.

**Ctrl+Left** and **Ctrl+Right** switch between Mac desktops without the slide animation.

Free and open source. Made for **macOS Tahoe 26**. [Website](https://hadi-almusawi.github.io/fast-space-switch/) | [Download](https://github.com/Hadi-Almusawi/fast-space-switch/releases/latest)

## Compatibility

| macOS | Status |
| --- | --- |
| 26 Tahoe | ✓ Supported |
| 27 | ✕ Not supported |
| 15 Sequoia and earlier | ? Not tested |

The release includes Apple Silicon and Intel code. Intel hardware has not been tested. The installer runs only on macOS 26.

## Install

1. [Download the ZIP](https://github.com/Hadi-Almusawi/fast-space-switch/releases/download/v1.2.0/FastSpaceSwitch-1.2.0.zip). If it has not unzipped, double-click it in Downloads.
2. Open Terminal and paste:

   ```sh
   cd ~/Downloads/FastSpaceSwitch-1.2.0 && ./install.sh --prebuilt
   ```

3. The installer copies FastSpaceSwitch to `~/Applications`, opens it, and sets it to open when you log in. Allow it in **System Settings > Privacy & Security > Accessibility** for instant Ctrl+Left/Right switching. macOS requires this access for the desktop switch gesture.

If you saved the folder somewhere else, type `cd ` in Terminal, drag the unzipped folder in, and press Return. Then run `./install.sh --prebuilt`.

You can delete the downloaded folder after installation. The app is locally signed but not notarized. If macOS blocks the first launch, use **Open Anyway** in **System Settings > Privacy & Security**.

### Homebrew

```sh
brew tap Hadi-Almusawi/fast-space-switch https://github.com/Hadi-Almusawi/fast-space-switch.git
brew trust --cask Hadi-Almusawi/fast-space-switch/fast-space-switch
brew install --cask Hadi-Almusawi/fast-space-switch/fast-space-switch
```

This installs the same app and also requires Accessibility access for instant Ctrl+Left/Right.

To build it yourself, install Apple's Xcode Command Line Tools, then run:

```sh
git clone https://github.com/Hadi-Almusawi/fast-space-switch.git
cd fast-space-switch
./install.sh
```

## Questions

**Why Accessibility access?** macOS requires it to send the desktop switch gesture. The app only receives its registered shortcuts. It does not record other keys, read your screen, or connect to the internet. There is no known way to make this exact instant Ctrl+Left/Right method work without that permission.

**Does it change other animations?** It sets the Dock's Mission Control and App Exposé animation time to zero. This can affect opening those views by trackpad too. Other Mac animations and Reduce Motion stay as they are. System Integrity Protection can stay on.

**Shortcut not working?** Check that the app is running and allowed in Accessibility. After a rebuild, remove its old permission entry and add it again. The app stops at the first and last desktop.

## Remove

Run `zsh "$HOME/Library/Application Support/FastSpaceSwitch/uninstall.sh"`. It removes the app and login item, then restores your previous desktop shortcut and Dock animation settings. Installs made before 1.2.0 did not save the desktop shortcut settings, so those upgrades restore the standard Mac shortcuts.

## Source and license

The app sends a very fast, tiny simulated trackpad swipe. It uses private macOS features, which may change in future updates. [Read how it works](https://hadi-almusawi.github.io/fast-space-switch/how-it-works.html) or [see the code](main.m).

Made by [Hadi Al-Musawi](https://github.com/Hadi-Almusawi). [MIT license](LICENSE).
