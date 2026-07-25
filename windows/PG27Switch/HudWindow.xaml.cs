using System.Windows;
using System.Windows.Media;
using System.Windows.Shapes;
using Forms = System.Windows.Forms;
using WpfInput = System.Windows.Input;

namespace PG27Switch;

public partial class HudWindow : Window
{
    public event Action? CancelRequested;

    private readonly HudPalette _palette;

    public HudWindow(InputSource source, Forms.Screen screen)
    {
        InitializeComponent();

        _palette = HudPalette.Current();
        ApplyPalette();
        TargetText.Text = source.Name;
        DrawIcon(source.IconKind);

        Left = screen.WorkingArea.Left + (screen.WorkingArea.Width - Width) / 2.0;
        Top = screen.WorkingArea.Top + (screen.WorkingArea.Height - Height) / 2.0;
    }

    public void SetCountdown(int number)
    {
        StatusText.Text = "切换屏幕输入源";
        CountdownText.Text = number.ToString();
        CountdownText.FontSize = 72;
        CountdownText.Foreground = _palette.PrimaryText;
        HintText.Text = "ESC 取消";
        HintText.Foreground = _palette.SecondaryText;
    }

    public void ShowCancelled()
    {
        StatusText.Text = "已取消";
        CountdownText.Text = "×";
        CountdownText.FontSize = 68;
        CountdownText.Foreground = _palette.CancelText;
        HintText.Text = "未切换屏幕输入源";
        HintText.Foreground = _palette.SecondaryText;
    }

    public void ShowSwitching()
    {
        StatusText.Text = "正在切换";
        CountdownText.Text = "…";
        CountdownText.FontSize = 72;
        CountdownText.Foreground = _palette.PrimaryText;
        HintText.Text = "请稍候";
    }

    public void ShowFailed()
    {
        StatusText.Text = "未完成";
        CountdownText.Text = "!";
        CountdownText.FontSize = 68;
        CountdownText.Foreground = Brushes.Orange;
        HintText.Text = "DDC 写入失败";
    }

    private void OnKeyDown(object sender, WpfInput.KeyEventArgs e)
    {
        if (e.Key == WpfInput.Key.Escape)
        {
            CancelRequested?.Invoke();
        }
    }

    private void ApplyPalette()
    {
        Panel.Background = _palette.PanelFill;
        Panel.BorderBrush = _palette.Border;
        TopAccent.Background = _palette.Accent;
        StatusText.Foreground = _palette.SecondaryText;
        TargetText.Foreground = _palette.PrimaryText;
        CountdownText.Foreground = _palette.PrimaryText;
        HintText.Foreground = _palette.SecondaryText;
    }

    private void DrawIcon(string kind)
    {
        IconCanvas.Children.Clear();
        var brush = _palette.Icon;

        switch (kind)
        {
            case "dp":
                IconCanvas.Children.Add(new Path
                {
                    Fill = brush,
                    Data = Geometry.Parse("M1.5 7.5C1.5 6.7 2.2 6 3 6H21C21.8 6 22.5 6.7 22.5 7.5V14.5C22.5 15.3 21.8 16 21 16H6.2C5.8 16 5.5 15.9 5.2 15.7L2.3 14.2C1.8 14 1.5 13.5 1.5 13V7.5ZM4.5 9V12H6V10.5H19V12H20.5V9H4.5Z")
                });
                break;
            case "hdmi":
                IconCanvas.Children.Add(new Path
                {
                    Fill = brush,
                    Data = Geometry.Parse("M2 8C2 6.9 2.9 6 4 6H20C21.1 6 22 6.9 22 8V13.5C22 14.6 21.1 15.5 20 15.5H17.8L15.8 18H8.2L6.2 15.5H4C2.9 15.5 2 14.6 2 13.5V8ZM5 9V12.7H7.8L9.8 15H14.2L16.2 12.7H19V9H5Z")
                });
                break;
            case "usbc":
                IconCanvas.Children.Add(new Path
                {
                    Fill = brush,
                    Data = Geometry.Parse("M7 8H17C19.2 8 21 9.8 21 12S19.2 16 17 16H7C4.8 16 3 14.2 3 12S4.8 8 7 8ZM7 10C5.9 10 5 10.9 5 12S5.9 14 7 14H17C18.1 14 19 13.1 19 12S18.1 10 17 10H7Z")
                });
                break;
            default:
                IconCanvas.Children.Add(new Path
                {
                    Fill = brush,
                    Data = Geometry.Parse("M4 5H20C21.1 5 22 5.9 22 7V16C22 17.1 21.1 18 20 18H14V20H17V22H7V20H10V18H4C2.9 18 2 17.1 2 16V7C2 5.9 2.9 5 4 5ZM4 7V16H20V7H4Z")
                });
                break;
        }
    }
}

internal sealed record HudPalette(
    System.Windows.Media.Brush PanelFill,
    System.Windows.Media.Brush Border,
    System.Windows.Media.Brush PrimaryText,
    System.Windows.Media.Brush SecondaryText,
    System.Windows.Media.Brush CancelText,
    System.Windows.Media.Brush Icon,
    System.Windows.Media.Brush Accent)
{
    public static HudPalette Current()
    {
        var light = Microsoft.Win32.Registry.GetValue(
            @"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
            "AppsUseLightTheme",
            0);

        var isLight = light is int value && value > 0;
        return isLight
            ? new HudPalette(
                BrushFrom("#E6E7E4"),
                BrushFrom("#A9ACA8"),
                BrushFrom("#1D2022"),
                BrushFrom("#5E6467"),
                BrushFrom("#8F5F63"),
                BrushFrom("#F1F0EA"),
                BrushFrom("#9F2024"))
            : new HudPalette(
                BrushFrom("#191B1C"),
                BrushFrom("#404244"),
                BrushFrom("#F2F2F0"),
                BrushFrom("#B6B9BA"),
                BrushFrom("#A8797D"),
                BrushFrom("#F0EFE9"),
                BrushFrom("#9F2024"));
    }

    private static SolidColorBrush BrushFrom(string color)
    {
        var brush = new SolidColorBrush((Color)ColorConverter.ConvertFromString(color));
        brush.Freeze();
        return brush;
    }
}
