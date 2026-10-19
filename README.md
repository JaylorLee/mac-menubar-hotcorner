# mac-menubar-hotcorner

把屏幕左上角变成菜单栏开关：在 macOS「自动隐藏和显示菜单栏」的 **仅在全屏幕视图下** 和 **永不** 之间切换。

基于 [Hammerspoon](https://www.hammerspoon.org/)，适合在全屏工作和观看视频时快速切换菜单栏显示方式。

## 使用效果

- 鼠标进入左上角立即触发，没有额外的停留延迟；以 50 毫秒间隔检测位置。
- 成功时静默切换，失败时显示提示。
- 停在角落只触发一次，离开角落约 24 个坐标单位后再进入，可以切回。
- 按住 Command、Option、Control、Shift、Fn 或鼠标按钮时暂停触发，避免影响拖动。
- 安全输入开启时暂停检测。
- 使用鼠标当前所在屏幕的左上角，支持多屏。

已在 macOS 27.0.1、Hammerspoon 1.1.1 上验证实际全屏切换。其他版本尚未验证，系统升级可能改变相关偏好键或通知。

## 安装

1. 安装并打开 [Hammerspoon](https://www.hammerspoon.org/)。也可以使用 Homebrew：

   ```sh
   brew install --cask hammerspoon
   ```

2. 先记录现有的左上角动作。在「系统设置 → 桌面与程序坞 → 触发角」中，把左上角设为 `-`，避免两个动作同时触发。其他三个角按需保留。

3. 下载本仓库，把 `menubar_corner.lua` 放入 `~/.hammerspoon/`。如果已有同名文件，请先备份。

4. 将 [init.example.lua](init.example.lua) 中的内容加入已有的 `~/.hammerspoon/init.lua`。如果该文件不存在，可以新建；已有配置无需整体替换。

5. 从 Hammerspoon 菜单选择 **Reload Config**。首次加载会自动启用，鼠标先离开左上角，再进入即可触发。

6. 如需登录后自动使用，在 Hammerspoon Preferences 中勾选 **Launch Hammerspoon at login**，并保持 Hammerspoon 运行。

此脚本在上述已验证环境中无需辅助功能、录屏或自动化权限。

## 暂停和恢复

菜单栏的 **角** 提供三个操作：

- **切换菜单栏自动隐藏方式**：手动切换一次。
- **暂停／启用左上角切换**：保存启用状态，下次加载继续使用该状态。
- **将左上角设为屏保并停用**：停用脚本，把原生左上角动作设为「启动屏幕保护程序」，不带修饰键。此操作会重启 Dock 以应用触发角设置。

最后一个操作固定设置为屏保，不会读取或恢复其他机器安装前的动作。若原来使用的是其他动作，请在系统设置中手动恢复。

卸载时，先暂停脚本，从 `init.lua` 删除对应内容，再删除 `menubar_corner.lua` 并 Reload Config；原生左上角动作按需手动恢复。

## 实现方式与限制

脚本读取 `AppleMenuBarVisibleInFullscreen`，在两种状态之间切换，同时将 `_HIHideMenuBar` 保持为 `false`，让桌面视图下的菜单栏始终显示。随后发送 `AppleInterfaceFullScreenMenuBarVisibilityChangedNotification`，让当前全屏窗口更新显示策略。

「系统设置 → 菜单栏」中的下拉框可能保留旧值，未必随脚本操作同步刷新。已验证的实际全屏显示行为可以正常切换，请以实际效果为准。

检测区域由 `menubar_corner.lua` 中的 `zone` 控制，默认为左上角 3 个坐标单位；定时器间隔为 `0.05` 秒。
