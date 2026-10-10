# fast-space-switch

Instant Ctrl+Left / Ctrl+Right desktop switching on macOS, with no slide animation.

It registers just those two hotkeys and, when one is pressed, posts a fake
trackpad swipe with a huge velocity so the Dock skips the animation. It does
nothing at the first or last desktop. No network, no files, no other input.

Built for macOS 26. macOS 27 changed the swipe format and needs a different
event (see InstantSpaceSwitcher's `iss_post_modern_dock_swipe`).

## Install

```sh
./install.sh
```

Then turn on FastSpaceSwitch in System Settings > Privacy & Security >
Accessibility. After every rebuild, remove it from that list and add it back,
since macOS treats each build as a new app.

`install.sh` turns off the built-in "Move left/right a space" shortcuts so
Ctrl+Arrow reaches the app.

## Uninstall

```sh
./uninstall.sh
```

Stops the app, removes the build, and restores the built-in shortcuts.

## Check

```sh
FastSpaceSwitch.app/Contents/MacOS/FastSpaceSwitch status   # which directions are open
```

## Credit

Swipe technique adapted from
[InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) by
jurplel (MIT).
