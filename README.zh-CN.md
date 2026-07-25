# PG27UCDM 输入源切换工具

[English](README.md)

`pg27switch` 用于切换 ASUS ROG Swift OLED PG27UCDM 的输入源，并显示带倒计时的原生 HUD。

## 平台

| 平台 | DDC 后端 | 主题 |
| --- | --- | --- |
| macOS 12+ | BetterDisplay | 跟随 macOS 外观 |
| Windows 11 | Windows Monitor Configuration API | `system`、`dark`、`light` |

## 下载

从 [GitHub Releases](https://github.com/kankankankankankan/pg27switch/releases) 下载 macOS 和 Windows 版本。

## 快速使用

macOS：

```bash
pg27switch hdmi1
pg27switch --preview dp
pg27switch --input dp --seconds 5
```

Windows PowerShell：

```powershell
& "D:\Tools\pg27switch.exe" hdmi1
& "D:\Tools\pg27switch.exe" --preview dp --seconds 3 --theme dark
& "D:\Tools\pg27switch.exe" --preview dp --seconds 3 --theme light
```

输入源：

```text
dp, displayport          DisplayPort  15
h1, hdmi1                HDMI 1       17
h2, hdmi2                HDMI 2       18
tc, typec, usb-c, usbc   Type-C       26
```

`--preview` 只显示 HUD，不切换显示器输入源。默认倒计时为 3 秒，可使用 `--seconds 1` 到 `--seconds 30` 调整。

## Stream Deck

macOS 使用 `macos/install.sh` 生成的启动文件，或使用 Mac Script Runner 执行 Zsh 命令。

Windows 为每个输入源创建一个快捷方式，在快捷方式目标中加入参数。例如：

```text
目标：D:\Tools\pg27switch.exe --preview dp --seconds 3 --theme dark
```

在 Stream Deck 使用 `System > Open` 打开快捷方式。Windows 程序使用 GUI 子系统启动，不会弹出黑色 CMD 窗口。

## 编译

macOS：

```bash
xcode-select --install
./macos/build.sh
```

Windows 需要 .NET 8 SDK：

```powershell
dotnet publish .\windows\PG27Switch\PG27Switch.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:IncludeAllContentForSelfExtract=true -p:PublishReadyToRun=true
```

推送版本 tag 会触发 GitHub Actions，同时构建 macOS 和 Windows：

```bash
git tag v1.3.16
git push origin v1.3.16
```

## 文档

- [macOS 使用说明](docs/usage.md)
- [Windows 使用说明](windows/README.md)

## 日志

macOS：

```text
~/Library/Logs/PG27UCDMSwitcher/pg27switch.log
```

Windows：

```text
%LOCALAPPDATA%\PG27Switch\pg27switch.log
```
