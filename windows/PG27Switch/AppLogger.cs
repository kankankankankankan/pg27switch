namespace PG27Switch;

internal static class AppLogger
{
    private static readonly string LogDirectory = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "PG27Switch");

    private static readonly string LogPath = Path.Combine(LogDirectory, "pg27switch.log");

    public static void Info(string message)
    {
        Write("INFO", message);
    }

    public static void Error(Exception exception)
    {
        Write("ERROR", exception.ToString());
    }

    private static void Write(string level, string message)
    {
        try
        {
            Directory.CreateDirectory(LogDirectory);
            File.AppendAllText(LogPath, $"{DateTimeOffset.Now:O} [{level}] {message}{Environment.NewLine}");
        }
        catch
        {
            // Logging must never prevent switching.
        }
    }
}
