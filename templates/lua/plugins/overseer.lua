-- ~/.config/nvim/lua/plugins/overseer.lua
return {
  { "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerInfo" },
    opts = {
      strategy = "terminal",
      task_list = { default_detail = 1, bindings = { ["q"] = "<cmd>close<cr>" } },
      templates = { "builtin" },
    },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>",    desc = "Run task (menu)" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
      { "<leader>rl", "<cmd>OverseerRunCmd<cr>", desc = "Run last cmd" },
      { "<leader>rk", function() require("overseer").run_action() end, desc = "Run action on task" },
      { "<leader>rm", function() require("overseer").run_template({ name = "make" }) end, desc = "Run Makefile target" },
      { "<leader>rp", function()
          local f = vim.fn.expand("%:p")
          require("overseer").new_task({
            cmd = "pytest", args = { "-v", f }, components = { "default" },
          }):start()
        end, desc = "Run pytest current file" },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      pcall(function()
        require("which-key").add({ { "<leader>r", group = "+run" } })
      end)
    end,
  },
}
