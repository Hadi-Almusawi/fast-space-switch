# FastSpaceSwitch 1.2.0

Instant Ctrl+Left and Ctrl+Right switching between macOS Spaces, without the slide animation.

- Free and open source under the MIT license.
- For macOS Tahoe 26. macOS 27 is not supported.
- Universal download: Apple Silicon and Intel code. Intel hardware is not tested.
- No network access, screen reading, or recording of other keys in the app.
- No need to turn off SIP.
- The installer now copies the app to `~/Applications` and opens it at login, so you can delete the downloaded folder after installation.
- New installs save the original Ctrl+Left/Right shortcut settings and restore them on uninstall.
- The installer stops on macOS versions other than 26 before changing settings.

## Install

Download `FastSpaceSwitch-1.2.0.zip` below and open it. In Terminal, paste:

```sh
cd ~/Downloads/FastSpaceSwitch-1.2.0 && ./install.sh --prebuilt
```

If you saved the folder somewhere else, type `cd `, drag the unzipped folder into Terminal, press Return, then run `./install.sh --prebuilt`.

The installer copies the app to `~/Applications`, opens it, and sets it to open at login. Allow FastSpaceSwitch in System Settings > Privacy & Security > Accessibility for instant Ctrl+Left/Right. macOS requires that access for the desktop switch gesture. You can delete the downloaded folder afterward.

The app is locally signed, not notarized by Apple. macOS may block the first launch. If you trust this project, use Privacy & Security > Open Anyway and reopen it. Building from source is also available.

The installer changes the two built-in Space shortcuts and saves your Dock animation setting. Run `zsh "$HOME/Library/Application Support/FastSpaceSwitch/uninstall.sh"` to remove the app and restore those settings.

[Website](https://hadi-almusawi.github.io/fast-space-switch/) | [Source and full instructions](https://github.com/Hadi-Almusawi/fast-space-switch)
