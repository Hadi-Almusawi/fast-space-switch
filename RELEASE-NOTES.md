# FastSpaceSwitch 1.0.0

Instant Ctrl+Left and Ctrl+Right switching between macOS Spaces, without the slide animation.

- Free and open source under the MIT license.
- For macOS Tahoe 26. macOS 27 is not supported.
- Universal download: Apple Silicon and Intel code. Intel hardware is not tested.
- No network access, screen reading, or recording of other keys in the app.
- No need to turn off SIP.

## Install

Download `FastSpaceSwitch-1.0.0.zip` below and open it. In Terminal, type `cd `, drag in the extracted folder, press Return, then run:

```sh
./install.sh --prebuilt
```

Allow FastSpaceSwitch in System Settings > Privacy & Security > Accessibility. Keep the extracted folder: the app runs from there.

The app is locally signed, not notarized by Apple. macOS may block the first launch. If you trust this project, use Privacy & Security > Open Anyway and reopen it. Building from source is also available.

The installer changes the two built-in Space shortcuts. Run `./uninstall.sh` from the same folder to remove the app and restore them.

[Website](https://hadi-almusawi.github.io/fast-space-switch/) | [Source and full instructions](https://github.com/Hadi-Almusawi/fast-space-switch)

The swipe technique comes from jurplel's InstantSpaceSwitcher (MIT).
