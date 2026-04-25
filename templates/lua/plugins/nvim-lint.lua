-- ~/.config/nvim/lua/plugins/nvim-lint.lua
return {
  { "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python         = { "ruff" },
        cpp            = { "cppcheck" },
        c              = { "cppcheck" },
        sh             = { "shellcheck" },
        bash           = { "shellcheck" },
        markdown       = { "markdownlint" },
        verilog        = { "verilator" },
        systemverilog  = { "verible" },
      }
      local v = lint.linters.verible
      if v then
        v.cmd = "verible-verilog-lint"
        v.args = { "--rules_config_search" }
      end
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() pcall(lint.try_lint) end,
      })
    end,
  },
}
