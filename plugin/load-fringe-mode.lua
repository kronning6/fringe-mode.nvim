vim.api.nvim_create_user_command("FringeModeToggle", function()
  require("fringe-mode").toggle_fringe_mode_windows()
end, {})

vim.api.nvim_create_user_command("FringeModeBalance", function()
  require("fringe-mode").balance_fringe_mode_windows()
end, {})

vim.api.nvim_create_user_command("FringeModeDebug", function()
  require("fringe-mode").debug()
end, {})
