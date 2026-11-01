# FastSpaceSwitch - Instant macOS Spaces Switching Without Animation

Switch between Mac desktops instantly with **Ctrl+Left** and **Ctrl+Right**. FastSpaceSwitch skips the sliding animation when you move between macOS Spaces.

It runs quietly in the background and stops at the first and last desktop.
It only receives its two registered shortcuts. The app does not read other
keys, read your screen, or connect to the internet.

Free and open source. Built for **macOS Tahoe 26**. macOS 27 is not supported. Older versions and Intel hardware have not been tested. The release download includes Apple Silicon and Intel code.

[Website](https://hadi-almusawi.github.io/fast-space-switch/) | [Download](https://github.com/Hadi-Almusawi/fast-space-switch/releases/latest) | [Report a problem](https://github.com/Hadi-Almusawi/fast-space-switch/issues)

## How to switch macOS desktops without the animation

1. [Download the latest release](https://github.com/Hadi-Almusawi/fast-space-switch/releases/latest) and open the ZIP.
2. Open Terminal. Type `cd `, drag the extracted folder into Terminal, and press Return.
3. Run `./install.sh --prebuilt`.
4. Allow FastSpaceSwitch in **System Settings > Privacy & Security > Accessibility**. Quit and reopen the app if needed.
5. Press **Ctrl+Left** or **Ctrl+Right**.

The download is locally signed, not notarized by Apple. macOS may block its first launch. Only if you trust the project, use **Privacy & Security > Open Anyway**, then reopen it. You can also build from source below. Keep the extracted folder after installing: the app runs from that folder.

### Build from source

Requires Apple's Xcode Command Line Tools. Install them with `xcode-select --install` if needed.

```sh
git clone https://github.com/Hadi-Almusawi/fast-space-switch.git
cd fast-space-switch
./install.sh
```

### Homebrew

Use this project's own tap:

```sh
brew tap Hadi-Almusawi/fast-space-switch https://github.com/Hadi-Almusawi/fast-space-switch.git
brew install --cask Hadi-Almusawi/fast-space-switch/fast-space-switch
```

Then allow Accessibility access. This installs the app inside Homebrew's folder and changes the same two shortcuts. macOS 27 is not supported. To remove a Homebrew install, use `brew uninstall --cask fast-space-switch`.

Then turn on FastSpaceSwitch in System Settings > Privacy & Security >
Accessibility. After every rebuild, remove it from that list and add it back,
since macOS treats each build as a new app.

`install.sh` turns off the built-in "Move left/right a space" shortcuts so
Ctrl+Arrow reaches the app.

To start it at login, add FastSpaceSwitch.app to Login Items yourself.

## Common questions

### How do I make Ctrl+Arrow switch desktops faster on Mac?

On macOS 26, run FastSpaceSwitch and allow Accessibility access. Ctrl+Left and Ctrl+Right then switch to the next desktop without the slide animation.

### Does it change Reduce Motion or trackpad swipes?

No. It only changes switching through its two shortcuts. Your trackpad and other Mac animations stay the same. It has no custom shortcuts or numbered-desktop shortcuts.

### Do I need to turn off SIP?

No. System Integrity Protection (SIP) can stay on.

### Why does macOS ask for Accessibility access?

macOS needs this permission before the app can send the gesture that switches desktops. The app only receives its two registered shortcuts. It does not record other keys, read your screen, or connect to the internet. Read [main.m](main.m) to check how it works.

### Does it work on macOS 27?

No. macOS 27 changed the gesture format. This version only uses the earlier format. See [InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) for other options.

### Why do the shortcuts not work?

Check that the app is running and allowed in Accessibility. After a rebuild, remove its old permission entry and add it again. Another app may be using the shortcuts. At the first or last desktop, the app stops rather than wrapping around.

## Uninstall

```sh
./uninstall.sh
```

Stops the app, removes the build, and restores the built-in shortcuts.
If you added the app to Login Items, remove it there too.

## How it works

The app sends a simulated trackpad swipe with very high speed and very little movement. This makes the Dock skip the slide. It uses private macOS features, which Apple may change in future updates.

[Read the technical explanation](https://hadi-almusawi.github.io/fast-space-switch/how-it-works.html). No speed benchmark is claimed.

## Check

```sh
FastSpaceSwitch.app/Contents/MacOS/FastSpaceSwitch status   # which directions are open
```

## Credit

Made by [Hadi Al-Musawi](https://github.com/Hadi-Almusawi). Free under the [MIT license](LICENSE).

Swipe technique adapted from
[InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) by
jurplel (MIT).
