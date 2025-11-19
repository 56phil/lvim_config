-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>uW", function()
  local old = vim.bo.textwidth
  vim.bo.textwidth = 0
  vim.cmd("normal! gggqG")
  vim.bo.textwidth = old
end, { desc = "Unwrap file" })

vim.keymap.set("n", "<leader>bw", ":write<CR>", { desc = "Write current buffer to DASD" })
vim.keymap.set("n", "<leader>bs", ":set spell!<CR>", { desc = "Toggle Spell Check" })
vim.keymap.set("n", "<leader>bc", ":RemoveContractions<CR>", { desc = "Remove contractions" })
vim.keymap.set("n", "<leader>ba", ":RemoveContractions all<CR>", { desc = "Remove contractions from all buffers" })
vim.keymap.set("n", "]s", "]s", { desc = "Next Spelling Error" })
vim.keymap.set("n", "[s", "[s", { desc = "Previous Spelling Error" })
vim.keymap.set("n", "z=", "z=", { desc = "Suggest Correction" })
