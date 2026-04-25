-- ~/.config/nvim/lua/plugins/motion.lua
return {
  { "ggandor/leap.nvim", event = "VeryLazy",
    config = function() require("leap").create_default_mappings() end,
  },
  { "machakann/vim-sandwich", event = "VeryLazy" },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "akinsho/toggleterm.nvim", event = "VeryLazy",
    opts = {
      direction = "float",
      float_opts = { border = "rounded" },
      open_mapping = [[<C-/>]],
    },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal: horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal: vertical" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",     desc = "Terminal: float" },
    },
  },
}
