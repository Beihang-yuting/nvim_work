-- ~/.config/nvim/lua/plugins/lang-tcl.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tclint = {
          cmd = { "tclint" },
          filetypes = { "tcl" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".git", "Makefile")(fname)
              or vim.fs.dirname(fname)
          end,
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "tcl" })
    end,
  },
}
