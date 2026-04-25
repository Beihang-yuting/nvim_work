-- ~/.config/nvim/lua/plugins/lang-sv.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        verible = {
          cmd = { "verible-verilog-ls", "--rules_config_search" },
          filetypes = { "systemverilog", "verilog" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".git", "Makefile", "*.f", "verible.filelist")(fname)
              or vim.fs.dirname(fname)
          end,
          on_new_config = function(config, _)
            local bufnr = vim.api.nvim_get_current_buf()
            local fl = vim.b[bufnr] and vim.b[bufnr].verible_filelist or nil
            if fl then
              config.cmd = { "verible-verilog-ls", "--file_list_path", fl }
            end
          end,
        },
      },
    },
  },
  { "nachumk/systemverilog.vim", ft = { "systemverilog", "verilog" } },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "verilog" })
    end,
  },
}
