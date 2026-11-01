# Website and release notes

## Check and publish

Run `python3 scripts/verify.py`. Run `zsh scripts/package.sh` on macOS to build a universal release ZIP without starting the app or changing shortcut settings. Update the version in the plist, package script, page, product facts, and release notes together.

The website is plain HTML and CSS. Pushing changes in `docs/` to main runs the Pages workflow. No analytics or outside fonts are needed.

The sitemap is at `https://hadi-almusawi.github.io/fast-space-switch/sitemap.xml`. This is a project site: a robots.txt inside this folder cannot control crawlers for the whole github.io host. Check the host's root robots.txt instead.

SoftwareApplication data describes the real app. There are no invented reviews or ratings. It does not promise a rich result. The llms.txt file lists product facts; it is not a ranking guarantee.

## Steps for the owner

1. Add the website as a URL-prefix property in Google Search Console. Use Google's HTML verification file and put it in `docs/`, then publish it. Submit the sitemap and request indexing of the homepage.
2. Add the same URL in Bing Webmaster Tools, verify it, and submit the sitemap. You can import a verified Search Console property.
3. If a demo would help, record two clean desktops with no private windows. Show normal Ctrl+Arrow switching, then FastSpaceSwitch. A short clip in the README is enough.
4. Share the project in relevant Mac communities where their rules allow it. Use the draft below and state that you made the app. Do not post the same message across unrelated discussions.
5. Ask early users for honest feedback and links when they recommend it. Do not buy stars, reviews, or links.
6. Once a month, check the prompts below in Google and the AI tools you use. Try each a few times and note the date, mentions, sources, and whether the compatibility facts are right.

## Share draft

I made FastSpaceSwitch, a small free Mac app that makes Ctrl+Left and Ctrl+Right switch desktops without the slide animation. It is for macOS Tahoe 26. It only registers those two shortcuts and does not connect to the internet. The source is small and open under the MIT license. It needs Accessibility access. macOS 27 is not supported yet. I would like feedback from people who switch between desktops often.

https://hadi-almusawi.github.io/fast-space-switch/

## Search prompts to check

- How do I disable the macOS Spaces switching animation?
- How do I make Ctrl+Arrow switch Mac desktops instantly?
- Free macOS Tahoe desktop switcher without animation
- Mac Spaces switcher without disabling SIP
- FastSpaceSwitch macOS compatibility

## Future distribution

The custom Homebrew cask lives in `Casks/fast-space-switch.rb`. Update its version and SHA-256 after building each new release ZIP. This is the project's own tap, not a listing in Homebrew's main cask repository. A full Homebrew install/uninstall needs a separate check on a test Mac because it changes shortcuts and starts the app.

An Apple Developer ID and notarization can remove much of the first-launch friction. That needs the owner's Apple developer account. No notarization is claimed for this release.
