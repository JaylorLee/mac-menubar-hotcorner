-- 把以下内容加入已有的 ~/.hammerspoon/init.lua，无需替换整个文件。
menuBarCorner = require('menubar_corner')
-- 首次安装时启用。后续启动状态由菜单中的启用/暂停选项保存。
if hs.settings.get('menubarCornerEnabled') == nil then
    menuBarCorner.start()
end
