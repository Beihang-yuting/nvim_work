-- ~/.config/nvim/lua/plugins/neovide.lua
if vim.g.neovide then
  vim.o.guifont                       = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_refresh_rate          = 60
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size     = 0.6
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_transparency          = 0.95
  vim.g.neovide_window_blurred        = true
  vim.g.neovide_remember_window_size  = true
  vim.g.neovide_input_use_logo        = true

  vim.keymap.set({ "n", "v" }, "<D-c>", '"+y',    { silent = true })
  vim.keymap.set({ "n", "v" }, "<D-v>", '"+P',    { silent = true })
  vim.keymap.set("i",          "<D-v>", "<C-r>+", { silent = true })
end

return {}
