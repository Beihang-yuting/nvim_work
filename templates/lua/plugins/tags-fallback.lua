-- ~/.config/nvim/lua/plugins/tags-fallback.lua
return {
  { "ludovicchabant/vim-gutentags", event = "BufReadPost",
    init = function()
      vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/gutentags"
      vim.g.gutentags_add_default_project_roots = 0
      vim.g.gutentags_project_root = { ".git", "Makefile", "*.f" }
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_ctags_extra_args = { "--fields=+l", "--c++-kinds=+p" }
    end,
  },
  { "dhananjaylatkar/cscope_maps.nvim",
    event = "BufReadPost",
    opts = {
      disable_maps = false,
      skip_picker_for_single_result = true,
      prefix = "<leader>j",
    },
  },
}
