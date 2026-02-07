# Chrome Splitter (macOS)

A lightweight macOS menu bar app that snaps the **frontmost Google Chrome window** to:

- Left half
- Right half
- Full visible screen

## Features (MVP)

- Menu bar app (no main window)
- Chrome-only window control
- Single-display optimized
- Global shortcuts:
  - Move Left: `Ctrl + Option + Left`
  - Move Right: `Ctrl + Option + Right`
  - Full Screen Area: `Ctrl + Option + Up`

## Requirements

- macOS 13+
- Xcode 15+ (or Swift 5.9+ toolchain)
- Accessibility permission enabled for this app

## Run

### Option 1: Xcode (recommended)

1. Open this folder in Xcode (`File` -> `Open...` and select the package).
2. Select the `ChromeSplitter` run target.
3. Run.
4. Grant Accessibility permission when prompted.

### Option 2: Terminal

```bash
swift build
swift run
```

When running from Terminal, grant Accessibility permission to the terminal app if prompted.

### Option 3: Build a double-clickable `.app`

```bash
./scripts/build_app.sh
open dist/ChromeSplitter.app
```

This creates `dist/ChromeSplitter.app` as a menu bar app.

### Option 4: Install from `.zip` (double-click and use)

If you received `ChromeSplitter-mac.zip`, you can install and run directly:

```bash
cd ~/Downloads
unzip -o ChromeSplitter-mac.zip
mv -f ChromeSplitter.app /Applications/
xattr -dr com.apple.quarantine /Applications/ChromeSplitter.app
open /Applications/ChromeSplitter.app
```

If macOS shows a security prompt, you can also right-click `ChromeSplitter.app` and choose `Open` once.

## Permission

This app uses macOS Accessibility APIs to resize/move windows.

Path:

`System Settings -> Privacy & Security -> Accessibility`

Enable permission for the running app (`ChromeSplitter.app`, Xcode, or Terminal).

## Scope Notes

- This version intentionally targets Google Chrome only.
- It is optimized for single-screen use (as defined in the MVP scope).
- No settings UI yet (shortcuts are currently fixed in code).
