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

local function get_cwd_for_pane(pane)
  local cwd = pane.current_working_dir
  if cwd and cwd.path then
    -- local home_directory = os.getenv('HOME')
    -- if home_directory then
    --   cwd.path = string.gsub(cwd.path, home_directory, '~')
    -- end
    return cwd.path
  end
  return nil
end

local function split_by_character(s, c)
  local parts = {}
  for part in string.gmatch(s, '[^' .. c .. ']+') do
    table.insert(parts, part)
  end
  return parts
end

wezterm.on(
  'format-tab-title',
  ---@diagnostic disable-next-line: unused-local, redefined-local
  function (tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local process = basename(pane.foreground_process_name)
    local cwd = get_cwd_for_pane(pane)
    local title = ""
    if process then
      title = process
    end
    if #tab.panes > 1 then
      title = title .. " (" .. #tab.panes .. "w)"
    end
    if cwd then
      local parts = split_by_character(cwd, '/')
      local last_part = parts[#parts]
      title = title .. " " .. last_part
    end
    return tab.tab_index .. ": " .. title .. " "
  end
)

wezterm.on(
  'format-window-title',
  ---@diagnostic disable-next-line: unused-local, redefined-local
  function (tab, pane, tabs, panes, config)
    local process = basename(pane.foreground_process_name)
    local cwd = get_cwd_for_pane(pane)
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
    if cwd then
      title = title .. " " .. cwd
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

