# PG27UCDM Input Switcher

[中文说明](README.zh-CN.md)

A macOS command line input switcher for the ASUS ROG Swift OLED PG27UCDM.

`pg27switch` shows a native macOS HUD on every connected display, counts down before switching, lets you cancel with ESC, then calls BetterDisplay to send the DDC input selection command.

Detailed usage: [docs/usage.md](docs/usage.md)

## Demo

![PG27UCDM input switcher HUD demo](assets/demo-hud.png)

## Features

- Native macOS HUD countdown
- ESC cancellation before switching
- Stream Deck friendly command line interface
- BetterDisplay DDC integration
- Short aliases for DisplayPort, HDMI 1, HDMI 2, and Type-C

## Requirements

- macOS 12 or later
- Xcode command line tools
- BetterDisplay installed at `/Applications/BetterDisplay.app`
- DDC access enabled for the PG27UCDM in BetterDisplay

Install Xcode command line tools if needed:

```bash
xcode-select --install
```

## Build

```bash
./macos/build.sh
```

Output:

```text
build/pg27switch
```

The build script uses `xcrun swiftc`, targets the current Mac architecture by default, and writes module cache files under `build/module-cache`.

Override the target if needed:

```bash
ARCH=arm64 MACOS_TARGET=12.0 ./macos/build.sh
```

```bash
ARCH=x86_64 MACOS_TARGET=12.0 ./macos/build.sh
```

## Cloud Build

This repository includes a GitHub Actions workflow at `.github/workflows/release.yml`.

Run a manual cloud build:

```text
GitHub repo -> Actions -> Build and Release -> Run workflow
```

Create a Release build:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow builds both `arm64` and `x86_64`, combines them into a universal macOS binary, then uploads:

```text
pg27switch-macos-universal.zip
pg27switch-macos-universal.zip.sha256
```

Tagged builds automatically create a GitHub Release.

## Run

Preview the HUD without switching:

```bash
./build/pg27switch --preview hdmi1
```

Switch input:

```bash
./build/pg27switch hdmi1
```

Show command help:

```bash
./build/pg27switch --help
```

Input shortcuts:

```text
dp, displayport          DisplayPort  15
h1, hdmi1                HDMI 1       17
h2, hdmi2                HDMI 2       18
tc, typec, usb-c, usbc   Type-C       26
```

## Install

```bash
./macos/install.sh
```

This installs the executable to:

```text
/usr/local/bin/pg27switch
```

Then run:

```bash
pg27switch --help
```

## Stream Deck

Use Mac Script Runner with language `Zsh`. Put one command per button:

```zsh
/usr/local/bin/pg27switch hdmi1
```

```zsh
/usr/local/bin/pg27switch hdmi2
```

```zsh
/usr/local/bin/pg27switch dp
```

```zsh
/usr/local/bin/pg27switch usbc
```

Use preview mode while setting up:

```zsh
/usr/local/bin/pg27switch --preview hdmi1
```

## Source Layout

```text
macos/Sources/ArgumentParser.swift       CLI parsing and help text
macos/Sources/BetterDisplayClient.swift  BetterDisplay command wrapper
macos/Sources/CountdownController.swift  HUD countdown and switch flow
macos/Sources/HUDWindow.swift            Native HUD window
macos/Sources/InputIconView.swift        Input source icons
macos/Sources/Logger.swift               File logger
macos/Sources/main.swift                 App entry point
macos/build.sh                           Build script
macos/install.sh                         Local install script
docs/usage.md                            Usage guide
```

## GitHub Upload

Before publishing, consider adding a license file such as `LICENSE`. Without a license, others do not have clear permission to reuse or contribute to the code.

Recommended files to commit:

```text
.gitignore
README.md
README.zh-CN.md
docs/
macos/
```

Generated files are ignored:

```text
build/
.DS_Store
macos/launchers/*.command
PG27UCDM_Input_Switcher_Development_Document.docx
```

Initialize and push:

```bash
git init
git add .gitignore README.md README.zh-CN.md docs macos
git commit -m "Initial PG27UCDM input switcher"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/pg27switch.git
git push -u origin main
```

## Logs

Logs are written to:

```text
~/Library/Logs/PG27UCDMSwitcher/pg27switch.log
```

If that directory is unavailable, the executable falls back to the system temporary directory.
