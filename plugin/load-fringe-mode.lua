vim.api.nvim_create_user_command("FringeModeToggle", function()
  require("fringe-mode").toggle_fringe_windows()
end, {})
