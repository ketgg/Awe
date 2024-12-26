local user        = require('config.user')
local colorscheme = require('theme.colorscheme.default')
local defwall     = require('gears.filesystem').get_configuration_dir() ..
		'theme/colorscheme/' .. (user.colorscheme or 'default') .. '/wallpaper.png'

local _M          = {}

_M.name           = 'default'

if user.colorscheme ~= nil then
	_M.name = user.colorscheme -- Name
	colorscheme = require('theme.colorscheme.' .. user.colorscheme)
end

_M.colors = colorscheme -- A table of colors
_M.wallpaper = user.wallpaper or defwall

return _M