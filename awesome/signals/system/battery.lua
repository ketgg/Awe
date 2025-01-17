local awful         = require('awful')
local upower_widget = require('modules.awesome-battery_widget')
local upower        = require('lgi').require('UPowerGlib')

awful.spawn.easy_async_with_shell(
  "echo $(upower -e | grep 'BAT' | head -n 1)", function(stdout)
    if upower.Client():get_devices() ~= nil then
      upower_widget({
        device_path = stdout:gsub("\n", ""),
        instant_update = true
      }):connect_signal("upower::update", function(_, device)
        -- print(device.state) -- 4.0 = charging
        local time_to_empty = device.time_to_empty / 60
        local time_to_full  = device.time_to_full / 60
        awesome.emit_signal("signal::battery",
          tonumber(string.format("%.0f", device.percentage)),
          device.state,
          tonumber(string.format("%.0f", time_to_empty)),
          tonumber(string.format("%.0f", time_to_full)),
          device.battery_level)
      end)
    end
  end)
