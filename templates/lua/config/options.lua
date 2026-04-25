-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

opt.tabstop        = 2
opt.shiftwidth     = 2
opt.softtabstop    = 2
opt.expandtab      = true

opt.number         = true
opt.relativenumber = true

opt.mouse          = "a"
opt.clipboard      = "unnamedplus"
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8

opt.ignorecase     = true
opt.smartcase      = true

opt.undofile       = true
opt.swapfile       = false
opt.backup         = false

opt.splitright     = true
opt.splitbelow     = true

opt.foldmethod     = "expr"
opt.foldexpr       = "nvim_treesitter#foldexpr()"
opt.foldenable     = false

opt.termguicolors  = true
opt.showmode       = false
opt.cmdheight      = 0
opt.pumheight      = 12

vim.filetype.add({
  extension = {
    sv  = "systemverilog",
    svh = "systemverilog",
    v   = "verilog",
    vh  = "verilog",
  },
})
