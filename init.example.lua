-- 把以下内容加入已有的 ~/.hammerspoon/init.lua，无需替换整个文件。
menuBarCorner = require('menubar_corner')
-- 实验配置：首次安装默认暂停，阅读 README 的已知问题后再手动启用。
if hs.settings.get('menubarCornerEnabled') == nil then
    hs.settings.set('menubarCornerEnabled', false)
end
