-- ~/.config/nvim/lua/plugins/ui-extras.lua
return {
  { "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = { override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      } },
      presets = { bottom_search = true, command_palette = true,
                  long_message_to_split = true, lsp_doc_border = true },
    },
  },

  { "rcarriga/nvim-notify",
    opts = { timeout = 2500, render = "compact", stages = "fade", top_down = false },
  },

  { "lukas-reineke/indent-blankline.nvim", main = "ibl",
    opts = { indent = { char = "│" }, scope = { show_start = false, show_end = false } },
  },

  { "echasnovski/mini.animate", event = "VeryLazy",
    opts = function()
      local an = require("mini.animate")
      return {
        cursor = { enable = true, timing = an.gen_timing.linear({ duration = 100, unit = "total" }) },
        scroll = { enable = true, timing = an.gen_timing.linear({ duration = 150, unit = "total" }) },
        resize = { enable = true },
        open   = { enable = false },
        close  = { enable = false },
      }
    end,
  },

  { "petertriho/nvim-scrollbar", event = "BufReadPost",
    opts = { handlers = { gitsigns = true, search = true } },
  },

  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },

  { "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "everforest"
      opts.options.globalstatus = true
      return opts
    end,
  },
}
