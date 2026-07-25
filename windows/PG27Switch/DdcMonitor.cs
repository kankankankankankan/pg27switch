using System.ComponentModel;
using System.Runtime.InteropServices;

namespace PG27Switch;

internal sealed class DdcMonitor : IDisposable
{
    public const byte InputSelectVcpCode = 0x60;

    public int Index { get; }
    public string Description { get; }
    public IntPtr Handle { get; }

    public DdcMonitor(int index, string description, IntPtr handle)
    {
        Index = index;
        Description = description;
        Handle = handle;
    }

    public uint? TryGetInputValue()
    {
        return NativeMethods.GetVCPFeatureAndVCPFeatureReply(
            Handle,
            InputSelectVcpCode,
            IntPtr.Zero,
            out var currentValue,
            out _) ? currentValue : null;
    }

    public void SetInputValue(uint value)
    {
        if (!NativeMethods.SetVCPFeature(Handle, InputSelectVcpCode, value))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), "SetVCPFeature failed.");
        }
    }

    public void Dispose()
    {
        NativeMethods.DestroyPhysicalMonitor(Handle);
    }
}

internal static class DdcController
{
    public static IReadOnlyList<DdcMonitor> Enumerate()
    {
        var result = new List<DdcMonitor>();
        NativeMethods.MonitorEnumProc callback = (hMonitor, _, _, _) =>
        {
            if (!NativeMethods.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor, out var count) || count == 0)
            {
                return true;
            }

            var physicalMonitors = new NativeMethods.PhysicalMonitor[count];
            if (!NativeMethods.GetPhysicalMonitorsFromHMONITOR(hMonitor, count, physicalMonitors))
            {
                return true;
            }

            foreach (var physical in physicalMonitors)
            {
                result.Add(new DdcMonitor(
                    result.Count,
                    physical.Description.TrimEnd('\0'),
                    physical.Handle));
            }

            return true;
        };

        if (!NativeMethods.EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, callback, IntPtr.Zero))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), "EnumDisplayMonitors failed.");
        }

        return result;
    }

    public static DdcMonitor SelectMonitor(IReadOnlyList<DdcMonitor> monitors, int? requestedIndex)
    {
        if (monitors.Count == 0)
        {
            throw new InvalidOperationException("No physical monitors found.");
        }

        if (requestedIndex is not null)
        {
            var match = monitors.FirstOrDefault(m => m.Index == requestedIndex.Value);
            return match ?? throw new ArgumentException($"Monitor index not found: {requestedIndex.Value}");
        }

        return monitors.FirstOrDefault(m => m.Description.Contains("PG27UCDM", StringComparison.OrdinalIgnoreCase))
            ?? monitors[0];
    }
}

internal static class NativeMethods
{
    public delegate bool MonitorEnumProc(IntPtr hMonitor, IntPtr hdcMonitor, IntPtr lprcMonitor, IntPtr dwData);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct PhysicalMonitor
    {
        public IntPtr Handle;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string Description;
    }

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumDisplayMonitors(
        IntPtr hdc,
        IntPtr lprcClip,
        MonitorEnumProc lpfnEnum,
        IntPtr dwData);

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        out uint pdwNumberOfPhysicalMonitors);

    [DllImport("dxva2.dll", SetLastError = true, CharSet = CharSet.Auto)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        uint dwPhysicalMonitorArraySize,
        [Out] PhysicalMonitor[] pPhysicalMonitorArray);

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool DestroyPhysicalMonitor(IntPtr hMonitor);

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetVCPFeature(IntPtr hMonitor, byte bVCPCode, uint dwNewValue);

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetVCPFeatureAndVCPFeatureReply(
        IntPtr hMonitor,
        byte bVCPCode,
        IntPtr pvct,
        out uint pdwCurrentValue,
        out uint pdwMaximumValue);
}
