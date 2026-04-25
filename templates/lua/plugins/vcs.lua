-- ~/.config/nvim/lua/plugins/vcs.lua
return {
  { "stevearc/overseer.nvim",
    keys = {
      { "<leader>vc", function() VcsCompile() end, desc = "VCS: compile" },
      { "<leader>vs", function() VcsSim() end,     desc = "VCS: simv (prompt testname)" },
      { "<leader>vS", function() VcsLast() end,    desc = "VCS: re-run last sim" },
      { "<leader>vq", function() VcsClean() end,   desc = "VCS: clean workspace" },
      { "<leader>vw", function() VcsWave() end,    desc = "VCS: open waveform tool" },
    },
    config = function(_, opts)
      require("overseer").setup(opts or {})
      vim.opt.errorformat:append([[Error-\[%t%n\]\ %m\,\ %f\,\ %l]])
      vim.opt.errorformat:append([[Warning-\[%t%n\]\ %m\,\ %f\,\ %l]])

      local last_test = nil

      function VcsCompile()
        require("overseer").new_task({
          name = "vcs compile",
          cmd  = "make", args = { "comp" },
          components = { "default", "on_output_quickfix" },
        }):start()
      end

      function VcsSim()
        local t = vim.fn.input("UVM_TESTNAME: ", last_test or "")
        if t == "" then return end
        last_test = t
        require("overseer").new_task({
          name = "simv +" .. t,
          cmd  = "make", args = { "sim", "TEST=" .. t },
          components = { "default", "on_output_quickfix" },
        }):start()
      end

      function VcsLast()
        if not last_test then vim.notify("没有上次测试"); return end
        VcsSim()
      end

      function VcsClean()
        require("overseer").new_task({
          name = "vcs clean", cmd = "make", args = { "clean" },
        }):start()
      end

      function VcsWave()
        local tool = vim.env.VCS_WAVE_TOOL or "verdi"
        require("overseer").new_task({ name = tool, cmd = tool, args = { "&" } }):start()
      end

      pcall(function()
        require("which-key").add({ { "<leader>v", group = "+vcs" } })
      end)

      vim.api.nvim_create_user_command("VcsCompile", VcsCompile, {})
      vim.api.nvim_create_user_command("VcsSim",     VcsSim,     {})
      vim.api.nvim_create_user_command("VcsLast",    VcsLast,    {})
      vim.api.nvim_create_user_command("VcsClean",   VcsClean,   {})
      vim.api.nvim_create_user_command("VcsWave",    VcsWave,    {})
    end,
  },
}
