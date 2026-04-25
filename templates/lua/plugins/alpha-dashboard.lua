-- ~/.config/nvim/lua/plugins/alpha-dashboard.lua
return {
  { "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[                                                ]],
        [[          gvim_work · Neovim · LazyVim          ]],
        [[                                                ]],
        [[       Multi-language code + hardware verif     ]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       ":Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files",    ":Telescope oldfiles<cr>"),
        dashboard.button("g", "  Live grep",       ":Telescope live_grep<cr>"),
        dashboard.button("c", "  Config",          ":e $MYVIMRC<cr>"),
        dashboard.button("?", "  Cheat sheet",     ":e ~/.config/nvim/CHEATSHEET.md<cr>"),
        dashboard.button("L", "  Lazy",            ":Lazy<cr>"),
        dashboard.button("M", "  Mason",           ":Mason<cr>"),
        dashboard.button("q", "  Quit",            ":qa<cr>"),
      }
      dashboard.section.footer.val = { "  press <Space>?h for the cheat sheet  " }
      return dashboard
    end,
    config = function(_, dashboard) require("alpha").setup(dashboard.config) end,
  },
}
