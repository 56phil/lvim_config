-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>bw", ":write<CR>", { desc = "Write current buffer to DASD" })
-- vim.keymap.set("n", "<leader>bc", ":ConvertEpigraph<CR>", { desc = "Convert all epigraphs to quotes" })
