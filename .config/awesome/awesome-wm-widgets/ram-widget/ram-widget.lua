local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

--- Main ram widget shown on wibar
local ramgraph_widget = wibox.widget {
    border_width = 0,
    colors = {
        '#f2be6e', '#42b874'
    },
    display_labels = false,
    forced_width = 30,
    widget = wibox.widget.piechart
}

--- Widget which is shown when user clicks on the ram widget
local w = wibox {
    height = 200,
    width = 400,
    ontop = true,
    screen = mouse.screen,
    expand = true,
    bg = '#4f4943',
    max_widget_size = 500
}

w:setup {
    border_width = 0,
    colors = {
		'#f66767', -- red
        --'#48c3ce', -- blue
        '#2abf77', -- green
        '#e5bf75', -- orange
    },
    display_labels = false,
    forced_width = 25,
    id = 'pie',
    widget = wibox.widget.piechart
}

local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

local function getPercentage(value)
    return math.floor(value / (total+total_swap) * 100 + 0.5) .. '%'
end

watch('bash -c "free | grep -z Mem.*Swap.*"', 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
            stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')

        widget.data = { used, total-used } widget.data = { used, total-used }

        if w.visible then
            w.pie.data_list = {
                {'used ' .. getPercentage(used + used_swap), used + used_swap},
                {'free ' .. getPercentage(free + free_swap), free + free_swap},
                {'buff_cache ' .. getPercentage(buff_cache), buff_cache}
            }
        end
    end,
    ramgraph_widget
)

ramgraph_widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()
            awful.placement.top_right(w, { margins = {top = 25, right = 10}})
            w.pie.data_list = {
                {'used ' .. getPercentage(used + used_swap), used + used_swap},
                {'free ' .. getPercentage(free + free_swap), free + free_swap},
                {'buff_cache ' .. getPercentage(buff_cache), buff_cache}
            }
            w.pie.display_labels = true
            w.visible = not w.visible
        end)
    )
)

return ramgraph_widget
