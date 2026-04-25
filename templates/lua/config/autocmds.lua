-- ~/.config/nvim/lua/config/autocmds.lua
local aug = vim.api.nvim_create_augroup
local au  = vim.api.nvim_create_autocmd

local sv = aug("UserSV", { clear = true })
au({ "BufRead", "BufNewFile" }, {
  group = sv,
  pattern = { "*.sv", "*.svh", "*.v", "*.vh" },
  callback = function(args)
    local roots = vim.fs.find({ ".git", "Makefile" }, {
      upward = true, path = vim.fs.dirname(args.file),
    })
    local root = roots[1] and vim.fs.dirname(roots[1]) or vim.fs.dirname(args.file)

    local f = vim.fn.glob(root .. "/*.f", false, true)
    local filelist
    if #f > 0 then
      filelist = f[1]
    else
      filelist = vim.fn.stdpath("cache") .. "/verible-" .. vim.fn.fnamemodify(root, ":t") .. ".f"
      local files = vim.fn.systemlist(string.format(
        "find %s -type f \\( -name '*.sv' -o -name '*.svh' \\) | head -2000",
        vim.fn.shellescape(root)))
      vim.fn.mkdir(vim.fn.fnamemodify(filelist, ":h"), "p")
      vim.fn.writefile(files, filelist)
    end
    vim.b.verible_filelist = filelist
  end,
})

au("TermOpen", { callback = function() vim.cmd("startinsert") end })

au("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

au("BufWritePre", {
  callback = function()
    if vim.bo.filetype == "markdown" then return end
    local cur = vim.api.nvim_win_get_cursor(0)
    pcall(vim.cmd, [[%s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
  end,
})
