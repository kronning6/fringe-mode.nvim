local M = {}

local state = {
  augroup = nil,
  left_win = nil,
  right_win = nil,
}

M.setup = function()
  if state.augroup then
    vim.api.nvim_clear_autocmds({ group = state.augroup })
  end

  state.augroup = vim.api.nvim_create_augroup("FringeMode", { clear = true })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = state.augroup,
    callback = function()
      local win_id = vim.api.nvim_get_current_win()
      if win_id == state.left_win or win_id == state.right_win then
        vim.cmd("wincmd p")
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = function()
      -- Handle resize events
    end,
  })
end

M.disable = function()
  if state.augroup then
    vim.api.nvim_clear_autocmds({ group = state.augroup })
    state.augroup = nil
  end
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

M.window_stats = function()
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
