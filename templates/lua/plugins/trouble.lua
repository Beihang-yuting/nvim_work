-- ~/.config/nvim/lua/plugins/trouble.lua
return {
  { "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true, focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                    desc = "Diagnostics: workspace" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",       desc = "Diagnostics: buffer" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                          desc = "Quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                         desc = "Location list" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",             desc = "Symbols" },
    },
  },
}
