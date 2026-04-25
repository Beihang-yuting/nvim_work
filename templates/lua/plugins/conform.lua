-- ~/.config/nvim/lua/plugins/conform.lua
return {
  { "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd  = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        cpp            = { "clang-format" },
        c              = { "clang-format" },
        python         = { "ruff_format", "black" },
        lua            = { "stylua" },
        systemverilog  = { "verible_verilog_format" },
        verilog        = { "verible_verilog_format" },
        sh             = { "shfmt" },
        markdown       = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
      formatters = {
        verible_verilog_format = {
          command = "verible-verilog-format",
          args = { "-" },
          stdin = true,
        },
      },
    },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
      { "<leader>uf", function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
        end, desc = "Toggle format-on-save" },
    },
  },
}
