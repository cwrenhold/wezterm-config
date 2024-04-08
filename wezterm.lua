-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Night Owl (Gogh)'

-- config.font = wezterm.font "FiraCode Nerd Font"
config.font = wezterm.font_with_fallback {
  "FiraCode Nerd Font",
  "monospace"
}

config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- config.enable_scroll_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on(
  'format-tab-title',
  ---@diagnostic disable-next-line: unused-local, redefined-local
  function (tab, tabs, panes, config, hover, max_width)
    local process = basename(tab.active_pane.foreground_process_name)
    local title = ""
    if process then
      title = process
    end
    if #tab.panes > 1 then
      title = title .. " (" .. #tab.panes .. "w)"
    end
    return tab.tab_index .. ": " .. title .. " "
  end
)

wezterm.on(
  'format-window-title',
  ---@diagnostic disable-next-line: unused-local, redefined-local
  function (tab, pane, tabs, panes, config)
    local process = basename(pane.foreground_process_name)
    local title = "wezterm@"
    if process then
      title = title .. process
    end
    if #tab.panes > 1 then
      title = title .. " (" .. #tab.panes .. "w)"
    end
    if #tabs > 1 then
      title = title .. " [" .. (tab.tab_index + 1) .. "/" .. #tabs .. "]"
    end
    return title
  end
)

-- Machine specific configuration
local hostname = wezterm.hostname()
local font_size = 12
if hostname == "MacBook-Pro" then
  font_size = 15
end

config.font_size = font_size

return config

