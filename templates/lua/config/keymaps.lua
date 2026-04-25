-- ~/.config/nvim/lua/config/keymaps.lua
local function map(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>?h", function()
  local f = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
  if vim.fn.filereadable(f) == 1 then
    vim.cmd("edit " .. f)
  else
    vim.notify("CHEATSHEET.md 不存在: " .. f, vim.log.levels.WARN)
  end
end, "Open cheat sheet")

map("n", "<leader>?", "<cmd>Telescope keymaps<cr>", "Search keymaps")

map({"n", "i"}, "<C-s>", "<cmd>w<cr>", "Save")

map("n", "<Esc><Esc>", "<cmd>nohlsearch<cr>", "Clear hlsearch")

map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

map({"n", "v"}, "<leader>d", '"_d', "Delete (no yank)")

map("n", "<C-]>", "<C-]>", "Tag jump (ctags fallback)")
