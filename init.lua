-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("chapterquote").setup()
require("config.minipage")
require("config.chapterquote")

vim.api.nvim_create_user_command("RemoveContractions", function(opts)
  require("remove_contractions").remove_contractions(opts)
end, {
  nargs = "?",
  complete = function()
    return { "all" }
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  command = "0r ~/.config/nvim/templates/skeleton.py",
})

vim.g.vimtex_compiler_enabled = 0
vim.api.nvim_set_hl(0, "StatusLineSpecial", { fg = "#ffffff", bg = "#aa0000", bold = true })
vim.o.statusline = "%#StatusLineSpecial#%{&buftype!='' ? '['.&buftype.'] ' : ''}%#StatusLine#%f %m %r %= %l:%c"
