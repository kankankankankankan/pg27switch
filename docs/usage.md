# PG27UCDM Input Switcher Usage

`pg27switch` is a macOS command line tool for switching ASUS ROG Swift OLED PG27UCDM input sources. It shows a native HUD on every connected display, starts a countdown, allows ESC cancellation, then calls BetterDisplay to send the DDC input selection command.

## Requirements

- macOS 12 or later on Apple Silicon
- BetterDisplay installed at `/Applications/BetterDisplay.app`
- DDC access enabled for the PG27UCDM in BetterDisplay

## Build

```bash
./macos/build.sh
```

The executable is written to:

```text
build/pg27switch
```

The build defaults to the current Mac architecture. Override it if needed:

```bash
ARCH=arm64 MACOS_TARGET=12.0 ./macos/build.sh
```

```bash
ARCH=x86_64 MACOS_TARGET=12.0 ./macos/build.sh
```

## Help

```bash
./build/pg27switch --help
```

## Inputs

```text
dp, displayport          DisplayPort  15
h1, hdmi1                HDMI 1       17
h2, hdmi2                HDMI 2       18
tc, typec, usb-c, usbc   Type-C       26
```

## Common Commands

Preview the HUD without switching:

```bash
./build/pg27switch --preview hdmi1
```

Switch to HDMI 1:

```bash
./build/pg27switch hdmi1
```

Switch to DisplayPort with a 5 second countdown:

```bash
./build/pg27switch --input dp --seconds 5
```

Switch with a raw DDC value:

```bash
./build/pg27switch --name "HDMI 1" --value 17
```

Preview a custom label:

```bash
./build/pg27switch --preview --name "Custom Input"
```

Use a custom BetterDisplay executable path:

```bash
./build/pg27switch hdmi1 --betterdisplay /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
```

## Options

```text
-i, --input INPUT          Input shortcut. Same as positional INPUT.
                           Accepted values are listed in Inputs.
                           If both positional INPUT and --input are provided, the last one wins.

--name NAME               Display name shown in the HUD.
                           Required when no INPUT or --input is provided.

--value VALUE             Raw PG27UCDM input value. Valid values: 15, 17, 18, 26.
                           Required for real switching when no INPUT or --input is provided.

--seconds N               Countdown seconds. Range: 1 to 30. Default: 3.

--preview                 Show the HUD only. BetterDisplay will not be called.
                           With --preview, --value is optional.

--betterdisplay PATH      BetterDisplay executable path.
                           Default: /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay

-h, --help                Show command help.
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

Use `--preview` during setup if you want to test the HUD without changing the monitor input:

```zsh
/usr/local/bin/pg27switch --preview hdmi1
```

## Install

```bash
./macos/install.sh
```

The installer builds the executable, copies it to:

```text
/usr/local/bin/pg27switch
```

It also generates Stream Deck launcher scripts:

```text
macos/launchers/DisplayPort.command
macos/launchers/HDMI1.command
macos/launchers/HDMI2.command
macos/launchers/TypeC.command
```

Bind Stream Deck buttons to those `.command` files with the built in Open action.

## Logs

Logs are written to:

```text
~/Library/Logs/PG27UCDMSwitcher/pg27switch.log
```

If that directory is unavailable, the tool falls back to the system temporary directory.

## Exit Codes

```text
0   Success or cancelled by ESC
1   Runtime error, such as missing BetterDisplay
2   Missing input value at switch time
64  Command line usage error
```

## Troubleshooting

If the HUD appears but the monitor does not switch, first confirm BetterDisplay can control DDC for the PG27UCDM. Then check the log file for the exact BetterDisplay command and stderr output.

If `--preview` works but a real switch exits with code `1`, verify the BetterDisplay executable path:

```bash
ls -l /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
```

If a shortcut is rejected, run:

```bash
./build/pg27switch --help
```

Then compare the input name with the aliases listed in the Inputs section.
