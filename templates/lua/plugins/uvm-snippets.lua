-- ~/.config/nvim/lua/plugins/uvm-snippets.lua
return {
  { "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      local user_dir = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(user_dir) == 1 then
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { user_dir } })
      end
      pcall(function()
        require("which-key").add({ { "<leader>U", group = "+uvm" } })
      end)
    end,
  },
}
