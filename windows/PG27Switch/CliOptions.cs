namespace PG27Switch;

internal sealed record CliOptions(
    InputSource? Source,
    bool PreviewOnly,
    bool ListOnly,
    int? MonitorIndex,
    int Seconds,
    HudTheme Theme,
    bool ShowHelp,
    bool ShowVersion);

internal enum HudTheme
{
    System,
    Light,
    Dark
}

internal static class CliParser
{
    public const string Usage = """
PG27UCDM Input Switcher for Windows

Usage:
  pg27switch.exe INPUT
  pg27switch.exe --input INPUT
  pg27switch.exe --preview INPUT
  pg27switch.exe --list
  pg27switch.exe --monitor INDEX INPUT
  pg27switch.exe --name NAME --value VALUE [--seconds N]

Inputs:
  dp, displayport          DisplayPort, DDC value 15
  h1, hdmi1                HDMI 1, DDC value 17
  h2, hdmi2                HDMI 2, DDC value 18
  tc, typec, usb-c, usbc   Type-C, DDC value 26

Options:
  --list                   List physical monitors and current input value when available.
  --monitor INDEX          Select a physical monitor index from --list.
  -i, --input INPUT        Input shortcut.
  --name NAME              Custom input name shown in the HUD.
  --value VALUE            Raw DDC value for VCP 0x60.
  --seconds N              Countdown seconds, 1 to 30. Default: 3.
  --theme THEME            HUD theme: system, light, or dark. Default: system.
  --preview                Show the HUD only and skip DDC switching.
  -v, --version            Show version.
  -h, --help               Show this help.
""";

    public static CliOptions Parse(string[] args)
    {
        InputSource? source = null;
        string? customName = null;
        uint? customValue = null;
        var previewOnly = false;
        var listOnly = false;
        int? monitorIndex = null;
        var seconds = 3;
        var theme = HudTheme.System;

        for (var i = 0; i < args.Length; i++)
        {
            var arg = args[i];
            switch (arg)
            {
                case "-h":
                case "--help":
                    return new CliOptions(null, false, false, null, seconds, theme, true, false);
                case "-v":
                case "--version":
                    return new CliOptions(null, false, false, null, seconds, theme, false, true);
                case "--preview":
                    previewOnly = true;
                    break;
                case "--list":
                    listOnly = true;
                    break;
                case "-i":
                case "--input":
                    source = ParseInput(RequireValue(args, ref i, arg));
                    break;
                case "--name":
                    customName = RequireValue(args, ref i, arg);
                    break;
                case "--value":
                    customValue = ParseUInt(RequireValue(args, ref i, arg), arg);
                    break;
                case "--monitor":
                    monitorIndex = ParseInt(RequireValue(args, ref i, arg), arg);
                    break;
                case "--seconds":
                    seconds = ParseInt(RequireValue(args, ref i, arg), arg);
                    if (seconds < 1 || seconds > 30)
                    {
                        throw new ArgumentException("--seconds must be between 1 and 30.");
                    }
                    break;
                case "--theme":
                    theme = ParseTheme(RequireValue(args, ref i, arg));
                    break;
                default:
                    if (arg.StartsWith('-'))
                    {
                        throw new ArgumentException($"Unknown argument: {arg}");
                    }
                    source = ParseInput(arg);
                    break;
            }
        }

        if (source is null && customName is not null)
        {
            if (!previewOnly && customValue is null)
            {
                throw new ArgumentException("Missing --value unless --preview is used.");
            }
            source = InputSource.FromCustom(customName, customValue ?? 0);
        }

        if (previewOnly && source is null)
        {
            source = InputSource.TryParse("dp", out var previewSource) ? previewSource : null;
        }

        if (!listOnly && source is null)
        {
            throw new ArgumentException("Missing input.");
        }

        return new CliOptions(source, previewOnly, listOnly, monitorIndex, seconds, theme, false, false);
    }

    private static string RequireValue(string[] args, ref int index, string key)
    {
        index++;
        if (index >= args.Length)
        {
            throw new ArgumentException($"Missing value for {key}.");
        }
        return args[index];
    }

    private static InputSource ParseInput(string value)
    {
        if (!InputSource.TryParse(value, out var source))
        {
            throw new ArgumentException($"Invalid input: {value}");
        }
        return source;
    }

    private static int ParseInt(string value, string key)
    {
        if (!int.TryParse(value, out var parsed))
        {
            throw new ArgumentException($"Invalid value for {key}: {value}");
        }
        return parsed;
    }

    private static uint ParseUInt(string value, string key)
    {
        if (!uint.TryParse(value, out var parsed))
        {
            throw new ArgumentException($"Invalid value for {key}: {value}");
        }
        return parsed;
    }

    private static HudTheme ParseTheme(string value)
    {
        return value.ToLowerInvariant() switch
        {
            "system" => HudTheme.System,
            "light" => HudTheme.Light,
            "dark" => HudTheme.Dark,
            _ => throw new ArgumentException($"Invalid theme: {value}. Use system, light, or dark.")
        };
    }
}
