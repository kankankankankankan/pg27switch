# PG27Switch Windows

Windows version of `pg27switch` for ASUS ROG Swift OLED PG27UCDM.

This version calls the Windows Monitor Configuration API directly. It does not depend on BetterDisplay or ControlMyMonitor.

The published executable uses the Windows GUI subsystem, so launching it from Stream Deck does not open a console window. Runtime diagnostics remain available in `%LOCALAPPDATA%\PG27Switch\pg27switch.log`.

## Commands

```powershell
pg27switch.exe --list
pg27switch.exe dp
pg27switch.exe hdmi1
pg27switch.exe hdmi2
pg27switch.exe usbc
pg27switch.exe --monitor 1 dp
pg27switch.exe --preview
pg27switch.exe --preview hdmi1
pg27switch.exe --preview dp --seconds 5
pg27switch.exe --preview dp --seconds 3 --theme dark
pg27switch.exe --preview dp --seconds 3 --theme light
```

## Input Values

```text
15  DisplayPort
17  HDMI 1
18  HDMI 2
26  Type-C
```

The input select VCP code is `0x60`.

## Build

Install .NET 8 SDK on Windows, then run:

```powershell
dotnet publish .\windows\PG27Switch\PG27Switch.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishReadyToRun=true
```

For the self contained WPF single file build, native WPF libraries must be extracted at runtime:

```powershell
dotnet publish .\windows\PG27Switch\PG27Switch.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:IncludeAllContentForSelfExtract=true -p:PublishReadyToRun=true
```

Output:

```text
windows\PG27Switch\bin\Release\net8.0-windows\win-x64\publish\pg27switch.exe
```

## Notes

Use `--list` first on the target Windows machine. Multi monitor setups can expose several physical monitor handles, and `--monitor INDEX` prevents switching the wrong display.

ControlMyMonitor can still be useful for checking DDC support and verifying VCP values during development.

Runtime logs are written to:

```text
%LOCALAPPDATA%\PG27Switch\pg27switch.log
```

Use `--theme system` to follow the Windows app theme, or select `--theme dark` and `--theme light` for Stream Deck buttons that should force a specific appearance.
