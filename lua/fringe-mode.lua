local util = require("util")

local M = {}

local state = {
  active = false,
  augroup = nil,
  left_win = nil,
  right_win = nil,
  wins = {},
}

local config = {
  bgcolor = nil,
  balance_windows = false,
}

local function is_fringe_mode_active()
  return state.active
end

local function is_fringe_mode_window(win_id)
  return state.left_win == win_id or state.right_win == win_id
end

local function reset_state()
  state.active = false

  if vim.api.nvim_win_is_valid(state.left_win) then
    vim.api.nvim_win_close(state.left_win, true)
  end
  state.left_win = nil

  if vim.api.nvim_win_is_valid(state.right_win) then
    vim.api.nvim_win_close(state.right_win, true)
  end
  state.right_win = nil
end

local function capture_window_info()
  -- TODO: Save window info needed to size windows
  local total_height = vim.o.lines
  local cmdheight = vim.o.cmdheight
  local statusline = vim.o.laststatus > 0 and 1 or 0
  local nvim_height = total_height - cmdheight - statusline
  local nvim_width = vim.o.columns

  local win_ids = vim.api.nvim_list_wins()

  print(string.format("Nvim:\n" .. "  Size: width=%d, height=%d\n", nvim_width, nvim_height))

  for _, win_id in ipairs(win_ids) do
    local win_config = vim.api.nvim_win_get_config(win_id)
    local win_info = vim.fn.getwininfo(win_id)[1]
    local buf = vim.api.nvim_win_get_buf(win_id)
    local buf_info = vim.fn.getbufinfo(buf)[1]
    util.print_table("win_config", win_config)
    util.print_table("win_info", win_info)
    util.print_table("win_info.variables", win_info.variables)
    print(vim.api.nvim_buf_get_name(buf))
    util.print_table("buf_info", buf_info)

    local row = win_config.row or win_info.winrow
    local col = win_config.col or win_info.wincol
    local height = vim.api.nvim_win_get_height(win_id)
    local width = vim.api.nvim_win_get_width(win_id)

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
        row,
        col,
        width,
        height,
        win_info.winnr,
        win_id == vim.api.nvim_get_current_win() and "yes" or "no"
      )
    )
  end
end

local function create_fringe_mode_windows()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

  if state.left_win == nil or not vim.api.nvim_win_is_valid(state.left_win) then
    state.left_win = vim.api.nvim_open_win(buf, false, {
      split = "left",
      height = 1,
      width = 1,
      style = "minimal",
    })
  end

  if state.right_win == nil or not vim.api.nvim_win_is_valid(state.right_win) then
    state.right_win = vim.api.nvim_open_win(buf, false, {
      split = "right",
      height = 1,
      width = 1,
      style = "minimal",
    })
  end

  if config.bgcolor then
    vim.api.nvim_win_set_option(state.left_win, "winhl", "Normal:FringeModeBackground")
    vim.api.nvim_win_set_option(state.right_win, "winhl", "Normal:FringeModeBackground")
  end
end

local function position_windows()
  vim.api.nvim_win_call(state.left_win, function()
    vim.cmd("wincmd H")
  end)

  vim.api.nvim_win_call(state.right_win, function()
    vim.cmd("wincmd L")
  end)
end

local function resize_windows()
  if config.balance_windows then
    vim.cmd("wincmd =")
  end

  local nvim_width = vim.o.columns
  local win_ids = vim.api.nvim_list_wins()

  local win_column_count = 0
  local win_width = 0
  for _, win_id in ipairs(win_ids) do
    -- Get window position and size
    local win_config = vim.api.nvim_win_get_config(win_id)

    -- Get window options
    local win_info = vim.fn.getwininfo(win_id)[1]

    local row = win_config.row or win_info.winrow
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

local function start_fringe_mode()
  if is_fringe_mode_active() then
    return
  end

  state.active = true
  -- capture_window_info()
  create_fringe_mode_windows()
  position_windows()
  resize_windows()
  -- capture_window_info()
end

local function prevent_move_into_fringe_window()
  if is_fringe_mode_active() then
    local win_id = vim.api.nvim_get_current_win()
    if is_fringe_mode_window(win_id) then
      vim.cmd("wincmd p")
    end
  end
end

function M.debug()
  util.print_debug_info()
end

function M.disable()
  if state.augroup then
    vim.api.nvim_clear_autocmds({ group = state.augroup })
    state.augroup = nil
  end
end

function M.setup()
  if state.augroup then
    M.disable()
  end

  vim.api.nvim_set_hl(0, "FringeModeBackground", { bg = "#1a1a1a" })

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
      if
        is_fringe_mode_active()
        and (
          (not vim.api.nvim_win_is_valid(state.left_win) and closed_win_id == state.right_win)
          or (not vim.api.nvim_win_is_valid(state.right_win) and closed_win_id == state.left_win)
        )
      then
        reset_state()
        vim.schedule(function()
          start_fringe_mode()
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinResized", {
    group = state.augroup,
    callback = function()
      -- TODO: Implement me
      if is_fringe_mode_active() then
        position_windows()
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = function()
      -- TODO: Implement me
    end,
  })
end

M.toggle_fringe_mode_windows = function()
  if not is_fringe_mode_active() then
    start_fringe_mode()
  else
    reset_state()
  end
end

return M
