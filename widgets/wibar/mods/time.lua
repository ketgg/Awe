local awful       = require("awful")
local wibox       = require("wibox")
local beautiful   = require("beautiful")
local dpi         = require("beautiful").xresources.apply_dpi
local helpers     = require("helpers")

return function ()
    local time     = wibox.widget {
        {
          {
            font = beautiful.font_nerd .. " 14",
            format = "%I:%M",
            align = "center",
            valign = "center",
            widget = wibox.widget.textclock
          },
          margins = { left = dpi(10), right = dpi(10) },
          widget = wibox.container.margin
        },
        buttons = {
          awful.button({}, 1, function()
            awesome.emit_signal('toggle::moment')
          end)
        },
        bg = beautiful.bg_light,
        widget = wibox.container.background,
        shape = helpers.rrect(2),
      }
      
      local finaltimewidget = wibox.widget {
        {
          time,
          layout = wibox.layout.fixed.horizontal,
        },
        spacing = 6,
        layout = wibox.layout.fixed.horizontal,
      }
      
      return finaltimewidget
end


