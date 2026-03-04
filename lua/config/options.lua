-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "73" -- column 73 marks overflow past column 72
vim.cmd([[highlight ColorColumn guibg=#3c3836]]) -- a muted dark gray for example
vim.opt.spellfile = vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")
