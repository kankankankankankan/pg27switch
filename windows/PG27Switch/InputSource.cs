namespace PG27Switch;

public sealed record InputSource(string Name, uint Value, string IconKind)
{
    private static readonly Dictionary<string, InputSource> Aliases = new(StringComparer.OrdinalIgnoreCase)
    {
        ["dp"] = new("DisplayPort", 15, "dp"),
        ["displayport"] = new("DisplayPort", 15, "dp"),
        ["h1"] = new("HDMI 1", 17, "hdmi"),
        ["hdmi1"] = new("HDMI 1", 17, "hdmi"),
        ["h2"] = new("HDMI 2", 18, "hdmi"),
        ["hdmi2"] = new("HDMI 2", 18, "hdmi"),
        ["tc"] = new("Type-C", 26, "usbc"),
        ["typec"] = new("Type-C", 26, "usbc"),
        ["usb-c"] = new("Type-C", 26, "usbc"),
        ["usbc"] = new("Type-C", 26, "usbc")
    };

    public static bool TryParse(string value, out InputSource source)
    {
        return Aliases.TryGetValue(value, out source!);
    }

    public static InputSource FromCustom(string name, uint value)
    {
        var lower = name.ToLowerInvariant();
        var icon = lower.Contains("displayport") ? "dp" :
            lower.Contains("hdmi") ? "hdmi" :
            lower.Contains("type") || lower.Contains("usb") ? "usbc" :
            "display";
        return new InputSource(name, value, icon);
    }
}
