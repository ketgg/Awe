-- Credits to Aproxia for the timeout animation logic.
-- https://github.com/Aproxia-dev

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local naughty   = require('naughty')
local wibox     = require('wibox')

local dpi       = beautiful.xresources.apply_dpi

local helpers   = require('helpers')

local _N        = {}

function _N.title(n)
	return wibox.widget({
		widget = wibox.container.scroll.horizontal,
		step_function = wibox.container.scroll.step_functions
				.waiting_nonlinear_back_and_forth,
		speed = 50,
		{
			widget = wibox.widget.textbox,
			markup =
					'<i>' .. ((n.title == nil or n.title == '') and 'AwesomeWM' or n.title) .. '</i>'
		}
	})
end

function _N.body(n)
	return wibox.widget({
		widget = wibox.container.background,
		fg     = beautiful.fg_normal .. 'cc',
		{
			widget = wibox.container.scroll.vertical,
			{
				widget = wibox.widget.textbox,
				markup = n.message
			}
		}
	})
end

function _N.icon(n)
	return wibox.widget({
		widget                = wibox.widget.imagebox,
		image                 = n.icon and helpers.cropSurface(1, gears.surface.load_uncached(n.icon))
				or beautiful.awesome_icon,
		buttons               = { awful.button(nil, 1, function() n:destroy() end) },
		horizontal_fit_policy = 'fit',
		vertical_fit_policy   = 'fit',
		forced_height         = dpi(32),
		forced_width          = dpi(32)
	})
end

function _N.timeout()
	return wibox.widget({
		widget           = wibox.widget.progressbar,
		max_value        = 100,
		value            = 0,
		background_color = beautiful.bg_light,
		color            = beautiful.accent,
		forced_height    = dpi(3)
	})
end

function _N.actions(n)
	return wibox.widget({
		widget          = naughty.list.actions,
		notification    = n,
		base_layout     = wibox.widget({
			layout  = wibox.layout.flex.horizontal,
			spacing = dpi(2)
		}),
		style           = {
			underline_normal   = false,
			underline_selected = false,
			bg_normal          = beautiful.bg_normal
		},
		widget_template = {
			widget = wibox.container.background,
			bg     = beautiful.mid_light .. '20',
			{
				widget  = wibox.container.margin,
				margins = dpi(3),
				{
					widget = wibox.container.place,
					halign = 'center',
					{
						widget = wibox.widget.textbox,
						font   = beautiful.font,
						id     = 'text_role'
					}
				}
			}
		}
	})
end

return function(n)
	-- Store original timeout and set it to an unreachable number.
	local timeout = n.timeout
	-- Using `math.huge` here breaks naughty :P.
	n.timeout = 999999
	local timeout_bar = _N.timeout()

	-- Sections, divided into blocks to avoid YandereDev levels of indentation.
	local titlebox = wibox.widget({
		widget = wibox.container.background,
		bg     = beautiful.mid_normal,
		{
			widget  = wibox.container.margin,
			margins = { bottom = dpi(1) },
			{
				widget = wibox.container.background,
				bg     = beautiful.bg_light,
				{
					widget  = wibox.container.margin,
					margins = {
						top = dpi(8),
						bottom = dpi(8),
						left = dpi(12),
						right = dpi(12)
					},
					{
						widget = wibox.container.place,
						halign = 'center',
						_N.title(n)
					}
				}
			}
		}
	})

	local contentbox = wibox.widget({
		layout = wibox.layout.align.vertical,
		{
			widget  = wibox.container.margin,
			margins = dpi(12),
			{
				widget  = wibox.layout.fixed.vertical,
				spacing = dpi(8),
				{
					layout = wibox.layout.align.horizontal,
					{
						layout = wibox.layout.fixed.horizontal,
						{
							widget   = wibox.container.constraint,
							strategy = 'max',
							width    = dpi(280),
							height   = dpi(250),
							{
								layout = wibox.layout.fixed.vertical,
								_N.body(n),
								{
									-- Add extra spacing to avoid having it look weird.
									widget  = wibox.container.margin,
									margins = { top = dpi(4) },
									-- This, however, makes you have to hide the spacing itself.
									visible = #n.actions > 0,
									_N.actions(n)
								}
							}
						},
						{
							widget        = wibox.widget.separator,
							color         = beautiful.red,
							forced_height = 1,
							forced_width  = dpi(12)
						}
					},
					nil,
					{
						layout = wibox.layout.align.vertical,
						_N.icon(n),
						nil,
						nil
					}
				}
			}
		},
		nil,
		{
			-- Today I learnt setting a constraint on a progress bar makes it use its minimum
			-- required size. The number you input into width doesn't matter.
			widget   = wibox.container.constraint,
			strategy = 'max',
			width    = 0,
			timeout_bar
		}
	})

	local layout = naughty.layout.box({
		notification    = n,
		cursor          = 'hand2',
		border_width    = 0,
		widget_template = {
			widget   = wibox.container.constraint,
			strategy = 'max',
			height   = dpi(320),
			width    = dpi(360),
			{
				widget   = wibox.container.constraint,
				strategy = 'min',
				width    = dpi(120),
				{
					widget       = wibox.container.background,
					bg           = beautiful.bg_normal,
					border_width = dpi(1),
					border_color = beautiful.red,
					{
						layout = wibox.layout.fixed.vertical,
						titlebox,
						contentbox
					}
				}
			}
		}
	})
	-- For some reason, doing this inside the `layout` declaration just doesn't work. You
	-- have to do it imperatively or it'll literally just get ignored.
	layout.buttons = {}

	-- Create an animation for the timeout.
	local anim = require('module.rubato').timed({
		intro      = 0,
		duration   = timeout,
		subscribed = function(pos, time)
			timeout_bar.value = pos
			if time == timeout then
				n:destroy()
				-- Call it twice because Lua.
				collectgarbage('collect')
				collectgarbage('collect')
			end
		end
	})
	-- Stop the timeout on notification hover.
	layout:connect_signal('mouse::enter', function() anim.pause = true end)
	layout:connect_signal('mouse::leave', function() anim.pause = false end)
	anim.target = 100

	return layout
end
