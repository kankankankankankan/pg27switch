using Forms = System.Windows.Forms;
using Wpf = System.Windows;

namespace PG27Switch;

internal static class Program
{
    [STAThread]
    public static int Main(string[] args)
    {
        try
        {
            AppLogger.Info($"Started with args: {string.Join(" ", args)}");
            var options = CliParser.Parse(args);
            if (options.ShowHelp)
            {
                ConsoleHelper.EnsureConsole();
                Console.WriteLine(CliParser.Usage);
                return 0;
            }

            if (options.ListOnly)
            {
                ConsoleHelper.EnsureConsole();
                using var monitors = new MonitorCollection(DdcController.Enumerate());
                foreach (var monitor in monitors.Items)
                {
                    var current = monitor.TryGetInputValue();
                    var currentText = current is null ? "unavailable" : current.Value.ToString();
                    Console.WriteLine($"{monitor.Index}: {monitor.Description}  input={currentText}");
                }
                return 0;
            }

            var source = options.Source ?? throw new ArgumentException("Missing input.");
            AppLogger.Info($"Parsed source={source.Name}, value={source.Value}, preview={options.PreviewOnly}, seconds={options.Seconds}");
            var app = new Wpf.Application
            {
                ShutdownMode = Wpf.ShutdownMode.OnExplicitShutdown
            };

            var controller = new CountdownRunner(source, options);
            app.Startup += (_, _) => controller.Start();
            return app.Run();
        }
        catch (Exception ex)
        {
            AppLogger.Error(ex);
            ConsoleHelper.EnsureConsole();
            Console.Error.WriteLine(ex.Message);
            Console.Error.WriteLine();
            Console.Error.WriteLine(CliParser.Usage);
            return 64;
        }
    }
}

internal sealed class CountdownRunner
{
    private readonly InputSource _source;
    private readonly CliOptions _options;
    private readonly List<HudWindow> _windows = [];
    private readonly System.Windows.Threading.DispatcherTimer _timer = new();
    private int _remaining;
    private bool _cancelled;
    private int _exitCode;

    public CountdownRunner(InputSource source, CliOptions options)
    {
        _source = source;
        _options = options;
        _remaining = options.Seconds;
    }

    public void Start()
    {
        AppLogger.Info($"Screen count: {Forms.Screen.AllScreens.Length}");
        foreach (var screen in Forms.Screen.AllScreens)
        {
            AppLogger.Info($"Creating HUD for screen {screen.DeviceName}, bounds={screen.Bounds}, workingArea={screen.WorkingArea}");
            var window = new HudWindow(_source, screen);
            window.CancelRequested += Cancel;
            _windows.Add(window);
            window.Show();
        }

        var firstWindow = _windows.FirstOrDefault();
        if (firstWindow is null)
        {
            throw new InvalidOperationException("No screens found.");
        }

        firstWindow.Activate();
        firstWindow.Focus();
        SetCountdown(_remaining);

        _timer.Interval = TimeSpan.FromSeconds(1);
        _timer.Tick += (_, _) => Tick();
        _timer.Start();
    }

    private void Tick()
    {
        _remaining--;
        if (_remaining > 0)
        {
            SetCountdown(_remaining);
            return;
        }

        _timer.Stop();
        if (_cancelled)
        {
            CloseSoon(450);
            return;
        }

        foreach (var window in _windows)
        {
            window.ShowSwitching();
        }

        if (_options.PreviewOnly)
        {
            CloseSoon(500);
            return;
        }

        try
        {
            using var monitors = new MonitorCollection(DdcController.Enumerate());
            var monitor = DdcController.SelectMonitor(monitors.Items, _options.MonitorIndex);
            monitor.SetInputValue(_source.Value);
            CloseSoon(500);
        }
        catch
        {
            _exitCode = 1;
            foreach (var window in _windows)
            {
                window.ShowFailed();
            }
            CloseSoon(1500);
        }
    }

    private void SetCountdown(int value)
    {
        foreach (var window in _windows)
        {
            window.SetCountdown(value);
        }
    }

    private void Cancel()
    {
        if (_cancelled)
        {
            return;
        }

        _cancelled = true;
        _timer.Stop();
        foreach (var window in _windows)
        {
            window.ShowCancelled();
        }
        CloseSoon(650);
    }

    private void CloseSoon(int milliseconds)
    {
        var closeTimer = new System.Windows.Threading.DispatcherTimer
        {
            Interval = TimeSpan.FromMilliseconds(milliseconds)
        };
        closeTimer.Tick += (_, _) =>
        {
            closeTimer.Stop();
            foreach (var window in _windows)
            {
                window.Close();
            }
            Wpf.Application.Current.Shutdown(_exitCode);
        };
        closeTimer.Start();
    }
}

internal sealed class MonitorCollection : IDisposable
{
    public IReadOnlyList<DdcMonitor> Items { get; }

    public MonitorCollection(IReadOnlyList<DdcMonitor> items)
    {
        Items = items;
    }

    public void Dispose()
    {
        foreach (var monitor in Items)
        {
            monitor.Dispose();
        }
    }
}
