local M = {}

-- Requirements
-- - Adds left and right fringe dynamically
-- - Can toggle on and off
-- - Adjusts size of fringe based on how many vertical splits there are
-- - Takes window width into account when calculating
-- - Takes zoom in and out (base calculations based on columns)
-- - Uses standard line widths into account when calculating (e.g. 80 and 120)
-- - Make fringe windows excluded from things like Ctrl-W o and opening a buffer in it

local state = {
  left_win = nil,
  right_win = nil,
}

M.setup = function()
  -- TODO: Implement me
end

local create_fringe_windows = function()
  -- local columns = vim.o.columns
  -- local lines = vim.o.lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local left_opts = {
    split = "left",
    width = 10,
    height = 1,
    style = "minimal",
  }

  state.left_win = vim.api.nvim_open_win(buf, false, left_opts)

  vim.api.nvim_win_call(state.left_win, function()
    vim.cmd("wincmd H")
  end)

  local right_opts = {
    split = "right",
    width = 10,
    height = 1,
    style = "minimal",
  }

  state.right_win = vim.api.nvim_open_win(buf, false, right_opts)

  vim.api.nvim_win_call(state.right_win, function()
    vim.cmd("wincmd L")
  end)

  vim.cmd("wincmd =")

  vim.api.nvim_win_set_width(state.left_win, 70)
  vim.api.nvim_win_set_width(state.right_win, 70)
end

M.toggle_fringe_windows = function()
  if state.left_win == nil and state.right_win == nil then
    create_fringe_windows()
  else
    vim.api.nvim_win_close(state.left_win, true)
    vim.api.nvim_win_close(state.right_win, true)
    state.left_win = nil
    state.right_win = nil
  end
end

return M
