local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')
local gears     = require('gears')
local dpi       = beautiful.xresources.apply_dpi
local buttons   = require('bindings.widgets.tasklist').buttons
local colors    = require('widgets.wibar.mods.colors')

return function(s)
   return awful.widget.tasklist {
      screen          = s,
      filter          = awful.widget.tasklist.filter.currenttags,
      buttons         = buttons,
      source          = function()
         local ret = {}
         for _, t in ipairs(s.tags) do
            gears.table.merge(ret, t:clients())
         end
         return ret
      end,
      style           = {
         disable_task_name = true,
         bg_normal         = colors.transparent,
         bg_focus          = colors.bg_light,
         bg_urgent         = colors.red_dark,
         bg_minimize       = colors.transparent,
         shape             = function(c, w, h)
            gears.shape.rounded_rect(c, w, h, dpi(1))
         end
      },
      layout          = {
         layout = wibox.layout.fixed.horizontal
      },
      widget_template = {
         widget = wibox.container.background,
         id     = 'background_role',
         {
            widget  = wibox.container.margin,
            margins = dpi(4),
            {
               widget = awful.widget.clienticon
            }
         }
      }
   }
end
