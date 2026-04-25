-- ~/.config/nvim/lua/plugins/align.lua
return {
  { "echasnovski/mini.align", event = "VeryLazy",
    opts = { mappings = { start = "ga", start_with_preview = "gA" } },
    keys = {
      { "ga", mode = { "n", "x" }, desc = "Align (mini, interactive)" },
      { "gA", mode = { "n", "x" }, desc = "Align with preview" },
    },
    config = function(_, opts)
      require("mini.align").setup(opts)

      local function par_align(split)
        return function()
          vim.cmd("normal! vip")
          require("mini.align").align_selected({ split_pattern = split })
        end
      end

      local function nmap(lhs, split, desc)
        vim.keymap.set("n", lhs, par_align(split), { desc = desc })
      end

      nmap("<leader>a=", "=",  "Align paragraph by =")
      nmap("<leader>a:", ":",  "Align paragraph by :")
      nmap("<leader>a,", ",",  "Align paragraph by ,")
      nmap("<leader>a|", "|",  "Align paragraph by |")
      nmap("<leader>a<", "<=", "Align paragraph by <= (SV nonblocking)")
      nmap("<leader>a/", "//", "Align paragraph by // (line comment)")
      vim.keymap.set("n", "<leader>aa", function()
        local s = vim.fn.input("Align by pattern: ")
        if s ~= "" then par_align(s)() end
      end, { desc = "Align by custom pattern" })
    end,
  },

  { "junegunn/vim-easy-align", keys = {
      { "<leader>aA", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Easy-align (interactive)" },
    },
  },

  { "folke/which-key.nvim", opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>a", group = "+align" })
      return opts
    end,
  },
}
