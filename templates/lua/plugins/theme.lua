-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.everforest_background = "soft"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
    end,
    config = function() vim.cmd.colorscheme("everforest") end,
  },
  { "sainnhe/gruvbox-material", lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "LazyVim/LazyVim", opts = { colorscheme = "everforest" } },
}
