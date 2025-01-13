local M = {}

function M.print_table(header, tbl)
  print(header)
  for key, value in pairs(tbl) do
    print("  ", key, value)
  end
end

function M.print_debug_info()
  local total_height = vim.o.lines
  local cmdheight = vim.o.cmdheight
  local usable_height = total_height - cmdheight

  local statusline = vim.o.laststatus > 0 and 1 or 0
  local actual_height = total_height - cmdheight - statusline

  print(string.format("Height %d: \n" .. "Height %d: \n" .. "Width: %d\n", usable_height, actual_height, vim.o.columns))

  -- Get a list of all window IDs
  local win_ids = vim.api.nvim_list_wins()

  -- Get detailed info about each window
  for _, win_id in ipairs(win_ids) do
    -- Get window position and size
    local config = vim.api.nvim_win_get_config(win_id)

    -- Get buffer in window
    local buf = vim.api.nvim_win_get_buf(win_id)

    -- Get window options
    local win_info = vim.fn.getwininfo(win_id)[1]

    print(
      string.format(
        "Window %d:\n"
          .. "  Buffer: %d\n"
          .. "  Position: row=%d, col=%d\n"
          .. "  Size: width=%d, height=%d\n"
          .. "  Winnr: %d\n"
          .. "  Is current: %s",
        win_id,
        buf,
        config.row or win_info.winrow,
        config.col or win_info.wincol,
        vim.api.nvim_win_get_width(win_id),
        vim.api.nvim_win_get_height(win_id),
        win_info.winnr,
        win_id == vim.api.nvim_get_current_win() and "yes" or "no"
      )
    )
  end
end

return M
