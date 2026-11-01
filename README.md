# FastSpaceSwitch

Switch between Mac desktops with **Ctrl+Left** and **Ctrl+Right**, without the slide animation.

**Ctrl+Up** opens Mission Control and **Ctrl+Down** shows the current app's windows. The installer sets the Dock's window-view animation time to zero for these built-in Mac shortcuts.

Free and open source. Made for **macOS Tahoe 26**. [Website](https://hadi-almusawi.github.io/fast-space-switch/) | [Download](https://github.com/Hadi-Almusawi/fast-space-switch/releases/latest)

## Compatibility

| macOS | Status |
| --- | --- |
| 26 Tahoe | ✓ Supported |
| 27 | ✕ Not supported |
| 25 and earlier | ? Not tested |

The release includes Apple Silicon and Intel code. Intel has not been tested.

## Install

1. [Download the latest ZIP](https://github.com/Hadi-Almusawi/fast-space-switch/releases/latest) and open it.
2. Open Terminal. Type `cd `, drag the extracted folder into Terminal, and press Return.
3. Run `./install.sh --prebuilt`.
4. Allow FastSpaceSwitch in **System Settings > Privacy & Security > Accessibility** for Ctrl+Left/Right.

Keep the extracted folder because the app runs from there. The download is locally signed but not notarized. macOS may ask you to use **Open Anyway** on first launch.

If you do not want to grant that permission, run `./install.sh --no-permission` instead. The app will not run. Ctrl+Left/Right use macOS's normal slide. Ctrl+Up/Down keep their Mac actions with the Dock animation time set to zero. The installer saves only your old Dock value in `~/Library/Application Support/FastSpaceSwitch/`. You can also turn on **Switch to Desktop 1, 2, ...** in **System Settings > Keyboard > Keyboard Shortcuts > Mission Control** for direct numbered jumps.

To build it yourself, install Apple's Xcode Command Line Tools, then run:

```sh
git clone https://github.com/Hadi-Almusawi/fast-space-switch.git
cd fast-space-switch
./install.sh
```

## Questions

**Why Accessibility access?** macOS requires it to send the desktop switch gesture. The app only receives its registered shortcuts. It does not record other keys, read your screen, or connect to the internet. There is no known way to make this exact instant Ctrl+Left/Right method work without that permission. Use `--no-permission` if you prefer macOS's normal switch.

**Does it change other animations?** It sets the Dock's Mission Control and App Exposé animation time to zero. This can affect opening those views by trackpad too. Other Mac animations and Reduce Motion stay as they are. System Integrity Protection can stay on.

**Shortcut not working?** Check that the app is running and allowed in Accessibility. After a rebuild, remove its old permission entry and add it again. The app stops at the first and last desktop.

## Remove

From the extracted folder, run `./uninstall.sh`. It removes the app, restores macOS's built-in desktop shortcuts, and puts your old Dock animation setting back. Remove it from Login Items too if you added it there.

## Source and license

The app sends a very fast, tiny simulated trackpad swipe. It uses private macOS features, which may change in future updates. [Read how it works](https://hadi-almusawi.github.io/fast-space-switch/how-it-works.html) or [see the code](main.m).

Made by [Hadi Al-Musawi](https://github.com/Hadi-Almusawi). [MIT license](LICENSE). Swipe technique adapted from [InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) by jurplel (MIT).
