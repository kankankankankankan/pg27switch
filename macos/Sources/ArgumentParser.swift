import Foundation

struct SwitchConfig {
    let name: String
    let value: Int?
    let seconds: Int
    let previewOnly: Bool
    let betterDisplayPath: String
}

private let inputAliases: [String: (name: String, value: Int)] = [
    "dp": ("DisplayPort", 15),
    "displayport": ("DisplayPort", 15),
    "h1": ("HDMI 1", 17),
    "hdmi1": ("HDMI 1", 17),
    "h2": ("HDMI 2", 18),
    "hdmi2": ("HDMI 2", 18),
    "tc": ("Type-C", 26),
    "typec": ("Type-C", 26),
    "usb-c": ("Type-C", 26),
    "usbc": ("Type-C", 26)
]

enum ArgumentError: Error, CustomStringConvertible {
    case help
    case missingValue(String)
    case invalidValue(String)
    case unknownArgument(String)
    case missingName
    case missingInputValue

    var description: String {
        switch self {
        case .help:
            return usage
        case .missingValue(let key):
            return "Missing value for \(key)"
        case .invalidValue(let value):
            return "Invalid value: \(value)"
        case .unknownArgument(let arg):
            return "Unknown argument: \(arg)"
        case .missingName:
            return "Missing --name"
        case .missingInputValue:
            return "Missing --value unless --preview is used"
        }
    }
}

let usage = """
PG27UCDM Input Switcher

Switch the ASUS ROG Swift OLED PG27UCDM input source with a native macOS
countdown HUD. Press ESC while the HUD is visible to cancel.

Usage:
  pg27switch INPUT
  pg27switch --input INPUT
  pg27switch --preview INPUT
  pg27switch --name NAME --value VALUE [--seconds N]
  pg27switch --preview --name NAME [--seconds N]

Arguments:
  INPUT                     Optional positional input shortcut.
                            Accepted values are listed in Inputs.
                            If INPUT is used, --name and --value are filled automatically.

Inputs:
  dp, displayport          DisplayPort, DDC value 15
  h1, hdmi1                HDMI 1, DDC value 17
  h2, hdmi2                HDMI 2, DDC value 18
  tc, typec, usb-c, usbc   Type-C, DDC value 26

Options:
  -i, --input INPUT          Input shortcut. Same as positional INPUT.
                             Accepted values are listed in Inputs.
                             If both positional INPUT and --input are provided, the last one wins.

  --name NAME               Display name shown in the HUD.
                             Required when no INPUT or --input is provided.
                             Examples: "HDMI 1", "DisplayPort", "Type-C".

  --value VALUE             Raw PG27UCDM input value sent through DDC.
                             Required for real switching when no INPUT or --input is provided.
                             Valid values:
                               15  DisplayPort
                               17  HDMI 1
                               18  HDMI 2
                               26  Type-C

  --seconds N               Countdown seconds before switching.
                             Range: 1 to 30.
                             Default: 3.

  --preview                 Show the HUD only. BetterDisplay will not be called.
                             Useful for testing icons, layout, countdown, and ESC cancel.
                             With --preview, --value is optional.

  --betterdisplay PATH      BetterDisplay executable path.
                             Default: /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
                             Use this only if BetterDisplay is installed somewhere else.

  -h, --help                Show this help.

Examples:
  pg27switch hdmi1
  pg27switch h1
  pg27switch --preview hdmi2
  pg27switch --input dp --seconds 5
  pg27switch --name "HDMI 1" --value 17
  pg27switch --preview --name "Custom Input"
  pg27switch hdmi1 --betterdisplay "/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"

Stream Deck:
  Use Mac Script Runner with language Zsh.
  Put one command per button:
    /usr/local/bin/pg27switch hdmi1
    /usr/local/bin/pg27switch hdmi2
    /usr/local/bin/pg27switch dp
    /usr/local/bin/pg27switch usbc

Behavior:
  1. Shows the HUD on every connected display.
  2. Counts down from --seconds.
  3. ESC cancels while the HUD is visible.
  4. After countdown, BetterDisplay is called to set VCP inputSelect.
  5. In --preview mode, step 4 is skipped.

BetterDisplay Calls:
  Primary:
    BetterDisplay set -namelike=PG27UCDM -ddc=VALUE -vcp=inputSelect
  Fallback:
    BetterDisplay set -namelike=PG27UCDM -feature=ddc -vcp=inputSelect -value=VALUE

Exit Codes:
  0   Success or cancelled by ESC.
  1   Runtime error, such as missing BetterDisplay.
  2   Missing input value at switch time.
  64  Command line usage error.

Logs:
  ~/Library/Logs/PG27UCDMSwitcher/pg27switch.log
"""

func parseArguments(_ args: [String]) throws -> SwitchConfig {
    var name: String?
    var value: Int?
    var seconds = 3
    var previewOnly = false
    var betterDisplayPath = "/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"
    var shortcut: String?

    var index = 1
    while index < args.count {
        let arg = args[index]
        switch arg {
        case "--help", "-h":
            throw ArgumentError.help
        case "--preview":
            previewOnly = true
        case "--input", "-i":
            index += 1
            guard index < args.count else { throw ArgumentError.missingValue(arg) }
            shortcut = args[index]
        case "--name":
            index += 1
            guard index < args.count else { throw ArgumentError.missingValue(arg) }
            name = args[index]
        case "--value":
            index += 1
            guard index < args.count else { throw ArgumentError.missingValue(arg) }
            guard let parsed = Int(args[index]) else { throw ArgumentError.invalidValue(args[index]) }
            value = parsed
        case "--seconds":
            index += 1
            guard index < args.count else { throw ArgumentError.missingValue(arg) }
            guard let parsed = Int(args[index]), parsed > 0, parsed <= 30 else {
                throw ArgumentError.invalidValue(args[index])
            }
            seconds = parsed
        case "--betterdisplay":
            index += 1
            guard index < args.count else { throw ArgumentError.missingValue(arg) }
            betterDisplayPath = args[index]
        default:
            if arg.hasPrefix("-") {
                throw ArgumentError.unknownArgument(arg)
            }
            shortcut = arg
        }
        index += 1
    }

    if let shortcut {
        let normalized = shortcut.lowercased()
        guard let match = inputAliases[normalized] else {
            throw ArgumentError.invalidValue(shortcut)
        }
        if name == nil {
            name = match.name
        }
        if value == nil {
            value = match.value
        }
    }

    guard let name else { throw ArgumentError.missingName }
    if !previewOnly, value == nil {
        throw ArgumentError.missingInputValue
    }

    if let value, ![15, 17, 18, 26].contains(value) {
        throw ArgumentError.invalidValue(String(value))
    }

    return SwitchConfig(
        name: name,
        value: value,
        seconds: seconds,
        previewOnly: previewOnly,
        betterDisplayPath: betterDisplayPath
    )
}
