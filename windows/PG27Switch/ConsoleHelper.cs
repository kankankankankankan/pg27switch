using System.Runtime.InteropServices;

namespace PG27Switch;

internal static class ConsoleHelper
{
    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool AttachConsole(uint dwProcessId);

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool AllocConsole();

    public static void EnsureConsole()
    {
        if (Console.IsOutputRedirected || Console.IsErrorRedirected)
        {
            return;
        }

        const uint attachParentProcess = 0xFFFFFFFF;
        if (!AttachConsole(attachParentProcess))
        {
            AllocConsole();
        }
    }
}
