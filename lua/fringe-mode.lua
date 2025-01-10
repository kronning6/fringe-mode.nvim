local M = {}

local state = {
  augroup = nil,
  left_win = nil,
  right_win = nil,
}

local is_fringe_mode_active = function()
  return state.left_win ~= nil
    and vim.api.nvim_win_is_valid(state.left_win)
    and state.right_win ~= nil
    and vim.api.nvim_win_is_valid(state.right_win)
end

local is_fringe_mode_window = function(win_id)
  return is_fringe_mode_active() and (state.left_win == win_id or state.right_win == win_id)
end

local resize_fringe_mode_windows = function()
  if is_fringe_mode_active() then
    local nvim_width = vim.o.columns
    local win_ids = vim.api.nvim_list_wins()

    local win_column_count = 0
    local win_width = 0
    for _, win_id in ipairs(win_ids) do
      -- Get window position and size
      local config = vim.api.nvim_win_get_config(win_id)

      -- Get window options
      local win_info = vim.fn.getwininfo(win_id)[1]

      local row = config.row or win_info.winrow
      local width = vim.api.nvim_win_get_width(win_id)

      if row == 1 and not is_fringe_mode_window(win_id) then
        win_column_count = win_column_count + 1
        win_width = win_width + width
      end
    end

    local fringe_width = math.max(math.floor((nvim_width - win_width) / 2), 0)

    vim.api.nvim_win_set_width(state.left_win, fringe_width)
    vim.api.nvim_win_set_width(state.right_win, fringe_width)
  end
end

local resize_windows = function()
  if is_fringe_mode_active() then
    vim.api.nvim_win_call(state.left_win, function()
      vim.cmd("wincmd H")
    end)

    vim.api.nvim_win_call(state.right_win, function()
      vim.cmd("wincmd L")
    end)

    vim.cmd("wincmd =")

    resize_fringe_mode_windows()
  end
end
local create_fringe_mode_windows = function()
  if is_fringe_mode_active() then
    return
  end


  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  state.left_win = vim.api.nvim_open_win(buf, false, {
    split = "left",
    height = 1,
    width = 1,
    style = "minimal",
  })

  state.right_win = vim.api.nvim_open_win(buf, false, {
    split = "right",
    height = 1,
    width = 1,
    style = "minimal",
  })

  vim.api.nvim_set_hl(0, "FringeModeBackground", { bg = "#1a1a1a" })
  vim.api.nvim_win_set_option(state.left_win, "winhl", "Normal:FringeModeBackground")
  vim.api.nvim_win_set_option(state.right_win, "winhl", "Normal:FringeModeBackground")

  resize_windows()
end

local prevent_move_into_fringe_window = function()
  local win_id = vim.api.nvim_get_current_win()
  if win_id == state.left_win or win_id == state.right_win then
    vim.cmd("wincmd p")
  end
end

M.window_stats = function()
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

M.disable = function()
  if state.augroup then
    vim.api.nvim_clear_autocmds({ group = state.augroup })
    state.augroup = nil
  end
end

M.toggle_fringe_mode_windows = function()
  if not is_fringe_mode_active() then
    create_fringe_mode_windows()
  else
    vim.api.nvim_win_close(state.left_win, true)
    vim.api.nvim_win_close(state.right_win, true)
    state.left_win = nil
    state.right_win = nil
  end
end

M.setup = function()
  if state.augroup then
    M.disable()
  end

  state.augroup = vim.api.nvim_create_augroup("FringeMode", { clear = true })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = state.augroup,
    callback = function()
      prevent_move_into_fringe_window()
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local closed_win_id = math.floor(tonumber(args.match) or -1)
    end,
  })

  vim.api.nvim_create_autocmd("WinResized", {
    group = state.augroup,
    callback = function(args)
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = function()
      -- resize_windows()
    end,
  })
end

return M
