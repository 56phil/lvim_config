-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Write all buffers
vim.keymap.set("n", "<leader>bW", ":wall<CR>", {
  desc = "Write all buffers to DASD",
  silent = true,
})

-- Buffer write
vim.keymap.set("n", "<leader>bw", ":write<CR>", {
  desc = "Write current buffer to DASD",
  silent = true,
})

-- Toggle spell check
vim.keymap.set("n", "<leader>bs", ":set spell!<CR>", {
  desc = "Toggle Spell Check",
  silent = true,
})

vim.keymap.set("n", "]s", "]s", { desc = "Next Spelling Error" })
vim.keymap.set("n", "[s", "[s", { desc = "Previous Spelling Error" })
vim.keymap.set("n", "z=", "z=", { desc = "Suggest Correction" })
vim.keymap.set("n", "<leader>bc", ":RemoveContractions<CR>", { desc = "Remove contractions" })
vim.keymap.set("n", "<leader>ba", ":RemoveContractions all<CR>", { desc = "Remove contractions from all buffers" })
