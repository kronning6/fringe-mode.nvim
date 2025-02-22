local util = require("util")

local M = {}

local state = {
  active = false,
  augroup = nil,
  left_win = nil,
  right_win = nil,
  wins = {},
  initial_resize_called = false,
}

---@class FringeModeOptions
local default_options = {
  bgcolor = nil,
  balance_windows = false,
  min_fringe_width = 10,
  widths = {
    normal = 128,
    narrow = 88,
  },
}

---@type FringeModeOptions
M.options = {}

local function is_fringe_mode_active()
  return state.active
end

local function is_fringe_mode_window(win_id)
  return state.left_win == win_id or state.right_win == win_id
end

local function reset_state()
  state.active = false
  state.initial_resize_called = false

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
  -- local total_height = vim.o.lines
  -- local cmdheight = vim.o.cmdheight
  -- local statusline = vim.o.laststatus > 0 and 1 or 0
  -- local nvim_height = total_height - cmdheight - statusline
  -- local nvim_width = vim.o.columns

  local win_ids = vim.api.nvim_list_wins()

  state.wins = {}
  for _, win_id in ipairs(win_ids) do
    local win_config = vim.api.nvim_win_get_config(win_id)
    local win_info = vim.fn.getwininfo(win_id)[1]
    -- util.print_table("win_config", win_config)
    -- util.print_table("win_info", win_info)
    -- util.print_table("win_info.variables", win_info.variables)

    local row = win_config.row or win_info.winrow
    local col = win_config.col or win_info.wincol
    local height = vim.api.nvim_win_get_height(win_id)
    local width = vim.api.nvim_win_get_width(win_id)

    table.insert(state.wins, {
      win_id = win_id,
      row = row,
      col = col,
      height = height,
      width = width,
    })
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

  if M.options.bgcolor then
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
  if M.options.balance_windows then
    vim.cmd("wincmd =")
  end

  local nvim_width = vim.o.columns
  local win_ids = vim.api.nvim_list_wins()

  local win_column_count = 0
  local wins = {}
  for _, win_id in ipairs(win_ids) do
    -- Get window position and size
    local win_config = vim.api.nvim_win_get_config(win_id)

    -- Get window options
    local win_info = vim.fn.getwininfo(win_id)[1]

    local row = win_config.row or win_info.winrow

    -- TODO: Track more than the top row to support horizontal splits
    if row == 1 and not is_fringe_mode_window(win_id) then
      win_column_count = win_column_count + 1
      table.insert(wins, win_id)
    end
  end

  local fringe_width = math.max(math.floor((nvim_width - (M.options.widths.normal * win_column_count)) / 2), 0)
  if fringe_width < M.options.min_fringe_width then
    fringe_width = math.max(math.floor((nvim_width - (M.options.widths.narrow * win_column_count)) / 2), 0)
  end

  vim.api.nvim_win_set_width(state.left_win, fringe_width)
  vim.api.nvim_win_set_width(state.right_win, fringe_width)
  for _, win_id in ipairs(wins) do
    vim.api.nvim_win_set_width(win_id, (nvim_width - (2 * fringe_width)) / win_column_count)
  end

  capture_window_info()
end

local function start_fringe_mode()
  if is_fringe_mode_active() then
    return
  end

  create_fringe_mode_windows()
  position_windows()
  resize_windows()
  state.active = true
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

---@param options FringeModeOptions|nil
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", default_options, options or {})

  if state.augroup then
    M.disable()
  end

  vim.api.nvim_set_hl(0, "FringeModeBackground", { bg = M.options.bgcolor })

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
      if is_fringe_mode_active() then
        if not state.initial_resize_called then
          state.initial_resize_called = true
        else
          -- TODO: Enable when function supports resizing after initial resize
          -- resize_windows()
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = function()
      if is_fringe_mode_active() then
        resize_windows()
      end
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

M.balance_fringe_mode_windows = function()
  if is_fringe_mode_active() then
    local fringe_width = math.max(
      math.floor((vim.api.nvim_win_get_width(state.left_win) + vim.api.nvim_win_get_width(state.right_win)) / 2),
      0
    )
    print(fringe_width)
    vim.api.nvim_win_set_width(state.left_win, fringe_width)
    vim.api.nvim_win_set_width(state.right_win, fringe_width)
  end
end

return M
