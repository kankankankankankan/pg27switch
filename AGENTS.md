# PG27Switch Agent Notes

This repository contains command line tools for switching the ASUS ROG PG27UCDM monitor input source.

## Current Scope

The app shows a native AppKit HUD, waits for a countdown, allows ESC cancellation, then calls BetterDisplay to send the DDC input source command.

The Windows implementation is under `windows/PG27Switch`. It uses WPF for the HUD and the Windows Monitor Configuration API for DDC/CI.

Current source layout:

```text
macos/Sources/ArgumentParser.swift       CLI parsing and usage text
macos/Sources/BetterDisplayClient.swift  BetterDisplay command wrapper
macos/Sources/CountdownController.swift  Countdown, ESC handling, app lifecycle
macos/Sources/HUDWindow.swift            Native HUD window and ROG visual style
macos/Sources/InputIconView.swift        Input source icons
macos/Sources/Logger.swift               File logger
macos/Sources/main.swift                 App entry point
macos/build.sh                           Local macOS build script
macos/install.sh                         Local install script
macos/preview/hud-preview.html           HTML visual preview for the HUD
windows/PG27Switch/                      Windows WPF and DDC/CI implementation
windows/README.md                        Windows usage and build notes
```

## HUD Design

The current HUD visual direction is ROG inspired:

```text
black or light gray main panel
small red accents
subtle gold line accents
low brightness gray bottom technical marks
top centered input icon
left top chevrons
right side rail
corner guide lines
micro grid and bottom symbol strip
```

Important design constraints:

```text
Do not add large red blocks.
Do not add glow or crystal highlight effects.
Do not use "20TH" text or 20th anniversary branding.
Keep the bottom symbol strip desaturated.
Keep the top input icon in a square ratio.
The DisplayPort icon should use the original 16 x 16 SVG path inside a square container.
Do not squeeze the top input icon into a wide short rectangle.
```

The previous icon issue came from forcing a 16 x 16 DisplayPort icon into a 42 x 20 or 28 x 16 container. The current fix uses a 34 x 34 top icon container and the original `InputIconView` SVG rendering path.

## Build And Install

Local build:

```sh
./macos/build.sh
```

Install current local binary:

```sh
./macos/install.sh
```

Manual install when needed:

```sh
cp build/pg27switch /usr/local/bin/pg27switch
chmod +x /usr/local/bin/pg27switch
shasum -a 256 build/pg27switch /usr/local/bin/pg27switch
```

The two shasum lines must match after install.

Preview without switching input:

```sh
pg27switch --preview dp --seconds 5
```

## Release Flow

GitHub Actions builds macOS universal binaries and Windows x64 binaries from tags matching `v*`.

Use tags like:

```text
v1.3.2
v1.3.3
```

The repository also has older tags such as `v1.0.0`, `v1.0.1`, and `v1.3.1`. Continue from the highest `v1.3.x` tag unless the owner says otherwise.

Release command example:

```sh
git tag v1.3.2
git push origin v1.3.2
```

## Files Not To Commit

Do not commit local build products or Finder metadata:

```text
build/
PG27UCDM/
macos/launchers/
.DS_Store
```

`build/` may reappear after local compilation. It is generated and should not be included in commits.

## Windows Version

Windows architecture:

```text
windows/
  PG27Switch/
```

Windows does not depend on BetterDisplay or ControlMyMonitor. It calls Windows monitor DDC APIs directly.

Relevant Windows API direction:

```text
EnumDisplayMonitors
GetPhysicalMonitorsFromHMONITOR
SetVCPFeature
DestroyPhysicalMonitors
```

Input select VCP code:

```text
0x60
```

Known PG27UCDM input values currently used by macOS version:

```text
15  DisplayPort
17  HDMI 1
18  HDMI 2
26  Type-C
```

Windows implementation should provide a similar CLI:

```text
pg27switch.exe dp
pg27switch.exe hdmi1
pg27switch.exe hdmi2
pg27switch.exe usbc
pg27switch.exe --preview dp --seconds 5
pg27switch.exe --list
pg27switch.exe --monitor 1 hdmi1
```

For Windows UI, WPF is the pragmatic first choice because it can recreate the current HUD style with transparent borderless windows, rounded corners, shadows, vector drawing, and simple packaging.

Local Windows build:

```powershell
dotnet publish .\windows\PG27Switch\PG27Switch.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishReadyToRun=true
```

This Mac may not have the .NET SDK installed. If `dotnet` is missing locally, validate through GitHub Actions.
