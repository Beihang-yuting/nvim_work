-- ~/.config/nvim/lua/plugins/search.lua
return {
  { "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function() pcall(require("telescope").load_extension, "frecency") end,
    keys = { { "<leader>fr", "<cmd>Telescope frecency<cr>", desc = "Frecency files" } },
  },
  { "kevinhwang91/nvim-bqf", ft = "qf",
    opts = { auto_enable = true, preview = { winblend = 5 } },
  },
  { "mrjones2014/legendary.nvim",
    cmd = { "Legendary" },
    keys = { { "<leader>?", "<cmd>Legendary<cr>", desc = "Legendary: search keymaps/commands" } },
    opts = { include_builtin = true, include_legendary_cmds = true },
  },
}
