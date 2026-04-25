-- ~/.config/nvim/lua/plugins/lang-cpp.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--cross-file-rename",
            "--all-scopes-completion",
            "--pch-storage=memory",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(
              "compile_commands.json", ".clangd", ".git",
              "CMakeLists.txt", "Makefile", "compile_flags.txt"
            )(fname)
          end,
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "make", "cmake" })
    end,
  },
}
