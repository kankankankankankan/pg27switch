# PG27Switch Windows

Windows 11 version for ASUS ROG Swift OLED PG27UCDM.

It uses the Windows Monitor Configuration API directly. BetterDisplay and ControlMyMonitor are not required.

## Download

Get `pg27switch-windows-x64.zip` from the [GitHub Releases](https://github.com/kankankankankankan/pg27switch/releases) page and extract `pg27switch.exe`.

## Commands

```powershell
pg27switch.exe dp
pg27switch.exe hdmi1
pg27switch.exe hdmi2
pg27switch.exe usbc
pg27switch.exe --preview dp
pg27switch.exe --list
pg27switch.exe --monitor 1 dp
```

Input values:

```text
DisplayPort  15
HDMI 1       17
HDMI 2       18
Type-C       26
```

`--preview` skips DDC switching. Without an input after `--preview`, DisplayPort is used. The default countdown is 3 seconds.

## Parameters

| Parameter | Description |
| --- | --- |
| `INPUT` | `dp`, `hdmi1`, `hdmi2`, or `usbc`. |
| `--input INPUT` | Input alias, equivalent to positional `INPUT`. |
| `--preview` | Show the HUD and skip DDC switching. Without `INPUT`, defaults to DisplayPort. |
| `--seconds N` | Countdown from 1 to 30 seconds. Default: 3. |
| `--theme system\|dark\|light` | Follow the Windows app theme or force a theme. |
| `--list` | List physical monitor handles and current input values. |
| `--monitor INDEX` | Select a monitor from `--list`. |
| `--name NAME` | Custom HUD label. |
| `--value VALUE` | Raw DDC value: 15, 17, 18, or 26. Required for real switching with `--name`. |
| `--help`, `-h` | Show help. |
| `--version`, `-v` | Show version. |

Custom input example:

```powershell
pg27switch.exe --name "HDMI 1" --value 17 --seconds 5
pg27switch.exe --preview --name "Office PC" --seconds 3 --theme light
```

## Theme and Countdown

```powershell
pg27switch.exe --preview dp --seconds 3 --theme system
pg27switch.exe --preview dp --seconds 3 --theme dark
pg27switch.exe --preview dp --seconds 3 --theme light
```

`system` follows the Windows app theme. `dark` and `light` force a theme. `--seconds` accepts values from 1 to 30.

## Stream Deck

Create one Windows shortcut per button. Example target:

```text
D:\Tools\pg27switch.exe --preview dp --seconds 3 --theme dark
```

In Stream Deck, use `System > Open` and select the shortcut. The published executable uses the GUI subsystem, so no console window appears.

## Build

Install the .NET 8 SDK, then run:

```powershell
dotnet publish .\windows\PG27Switch\PG27Switch.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:IncludeAllContentForSelfExtract=true -p:PublishReadyToRun=true
```

The executable is written to the publish directory under:

```text
windows\PG27Switch\bin\Release\net8.0-windows\win-x64\publish\pg27switch.exe
```

## Logs and DDC

Logs:

```text
%LOCALAPPDATA%\PG27Switch\pg27switch.log
```

Use `--list` to inspect physical monitors. Use `--monitor INDEX` when multiple monitor handles are present.
