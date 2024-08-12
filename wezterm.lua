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
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 40 -- if there's space, make the tabs wider so more of the path is visible
config.show_new_tab_button_in_tab_bar = false

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
    local home_directory = os.getenv('HOME')
    local path = cwd.path
    if home_directory then
      return string.gsub(path, home_directory, '~')
    end
    return path
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

    title = title .. " " .. tab.tab_index .. ": "

    if process then
      title = title .. process
    end

    if #tab.panes > 1 then
      title = title .. " (" .. #tab.panes .. "p)"
    end

    if cwd then
      local parts = split_by_character(cwd, '/')
      local last_part = parts[#parts]

      -- Based on the number of parts, determine the number of characters to display
      local num_chars
      if #parts > 5 then
        num_chars = 1
      elseif #parts > 3 then
        num_chars = 2
      elseif #parts > 1 then
        num_chars = 4
      end

      -- For everything except the last part, just take the first characters for display
      local trimmed_parts = {}
      for i = 1, #parts - 1 do
        table.insert(trimmed_parts, string.sub(parts[i], 1, num_chars))
      end

      -- If there were any trimmer parts then include them, otherwise just the last part
      if #trimmed_parts > 0 then
        local display_parts = table.concat(trimmed_parts, '/')
        title = title .. " " .. display_parts .. "/" .. last_part
      else
        title = title .. " " .. last_part
      end
    end

    return title .. " "
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
      title = title .. " (" .. #tab.panes .. "p)"
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

---@diagnostic disable-next-line: unused-local
wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M'

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    -- { Attribute = { Underline = 'Single' } },
    -- { Text = wezterm.hostname() .. ' ' .. date .. ' '  },
    { Text = date .. ' '  },
  })
end)

-- Machine specific configuration
local hostname = wezterm.hostname()
local font_size = 12
if hostname == "JUN0844" then
  font_size = 15
end

config.font_size = font_size

return config

