-- ~/.config/nvim/after/ftplugin/systemverilog.lua
vim.bo.commentstring = "// %s"
vim.bo.tabstop       = 2
vim.bo.shiftwidth    = 2
vim.bo.expandtab     = true
vim.opt_local.iskeyword:append("$")
vim.opt_local.matchpairs:append("<:>")
