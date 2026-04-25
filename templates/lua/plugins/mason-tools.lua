-- ~/.config/nvim/lua/plugins/mason-tools.lua
return {
  { "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    opts = {
      ensure_installed = {
        "verible", "clangd", "pyright", "lua-language-server", "tclint",
        "verible-verilog-format", "clang-format", "ruff", "black", "stylua", "shfmt",
        "verible-verilog-lint", "verilator", "cppcheck", "shellcheck", "markdownlint",
        "debugpy",
      },
      run_on_start = true,
      auto_update = false,
    },
    config = function(_, opts) require("mason-tool-installer").setup(opts) end,
  },
}
