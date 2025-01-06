vim.api.nvim_create_user_command("FringeModeToggle", function()
  require("fringe-mode").toggle_fringe_windows()
end, {})

vim.api.nvim_create_user_command("FringeModeStats", function()
  require("fringe-mode").window_stats()
end, {})
