-- ~/.config/nvim/lua/plugins/language-extras.lua
return {
  { "antoinemadec/vim-verilog-instance",
    ft = { "systemverilog", "verilog" },
    keys = {
      { "<leader>Ui", "<cmd>VerilogInstance<cr>", desc = "Verilog: instance current module",
        ft = { "systemverilog", "verilog" } },
    },
  },
  { "vhda/verilog_systemverilog.vim", ft = { "systemverilog", "verilog" } },
}
