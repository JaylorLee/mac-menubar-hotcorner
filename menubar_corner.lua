-- 左上角切换：仅在全屏幕视图下 / 永不。无需辅助功能或录屏权限。
local M = {enabled = false, busy = false}
local log = hs.logger.new('menubarCorner', 'info')
local zone = 3
local latched = true -- 启动时必须先离开角落
local settingsNotification = 'AppleInterfaceFullScreenMenuBarVisibilityChangedNotification'

local function readBool(key)
    local value, ok = hs.execute('/usr/bin/defaults read -g ' .. key)
    if not ok then return false end
    value = (value or ''):gsub('%s+', ''):lower()
    return value == '1' or value == 'true' or value == 'yes'
end

function M.toggle()
    if M.busy then return false end
    M.busy = true
    local visible = not readBool('AppleMenuBarVisibleInFullscreen')
    local _, ok = hs.execute('/usr/bin/defaults write -g _HIHideMenuBar -bool false && /usr/bin/defaults write -g AppleMenuBarVisibleInFullscreen -bool ' .. tostring(visible))
    if ok and readBool('AppleMenuBarVisibleInFullscreen') == visible and not readBool('_HIHideMenuBar') then
        hs.distributednotifications.post(settingsNotification)
        local mode = visible and '永不' or '仅在全屏幕视图下'
        log.i('切换成功：' .. mode)
        M.lastMode = mode
    else
        log.e('无法写入菜单栏设置')
        hs.alert.show('菜单栏切换失败，请查看 Hammerspoon 控制台', 2)
    end
    M.busy = false
    return ok
end

local function checkCorner()
    if not M.enabled or M.busy then return end
    if hs.eventtap.isSecureInputEnabled() then return end
    local p = hs.mouse.absolutePosition()
    local screen = hs.mouse.getCurrentScreen()
    if not screen then return end
    local f = screen:fullFrame()
    local inside = p.x >= f.x and p.x <= f.x + zone and p.y >= f.y and p.y <= f.y + zone
    if not inside then
        if p.x > f.x + 24 or p.y > f.y + 24 then latched = false end
        return
    end
    if latched then return end
    -- 按住修饰键或鼠标按钮时不触发，避免影响拖动和菜单操作。
    local flags = hs.eventtap.checkKeyboardModifiers()
    local buttons = hs.eventtap.checkMouseButtons()
    if flags.cmd or flags.alt or flags.ctrl or flags.shift or flags.fn or next(buttons) then return end
    latched = true
    M.toggle()
end

function M.start()
    M.enabled = true
    hs.settings.set('menubarCornerEnabled', true)
    latched = true
    if M.timer then M.timer:stop() end
    M.timer = hs.timer.doEvery(0.05, checkCorner)
    log.i('左上角切换已启用')
end

function M.stop()
    M.enabled = false
    hs.settings.set('menubarCornerEnabled', false)
    if M.timer then M.timer:stop() end
    log.i('左上角切换已暂停')
end

function M.restore()
    M.stop()
    local _, ok = hs.execute('/usr/bin/defaults write com.apple.dock wvous-tl-corner -int 5 && /usr/bin/defaults write com.apple.dock wvous-tl-modifier -int 0')
    if ok then
        hs.execute('/usr/bin/killall Dock')
        hs.alert.show('左上角已设为：启动屏幕保护程序', 2)
    end
end

M.menu = hs.menubar.new()
if M.menu then
    M.menu:setTitle('角')
    M.menu:setTooltip('左上角切换菜单栏自动隐藏方式')
    M.menu:setMenu(function()
        return {
            {title = '切换菜单栏自动隐藏方式', fn = M.toggle},
            {title = M.enabled and '暂停左上角切换' or '启用左上角切换', fn = function() if M.enabled then M.stop() else M.start() end end},
            {title = '-'},
            {title = '将左上角设为屏保并停用', fn = M.restore},
        }
    end)
end
if hs.settings.get('menubarCornerEnabled') then M.start() end
return M
