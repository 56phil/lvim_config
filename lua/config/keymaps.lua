-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>bw", ":write<CR>", { desc = "Write current buffer to DASD" })
vim.keymap.set("n", "<leader>bs", ":set spell!<CR>", { desc = "Toggle Spell Check" })
vim.keymap.set("n", "<leader>bc", ":RemoveContractions<CR>", { desc = "Remove contractions" })
vim.keymap.set("n", "<leader>ba", ":RemoveContractions all<CR>", { desc = "Remove contractions from all buffers" })
vim.keymap.set("n", "]s", "]s", { desc = "Next Spelling Error" })
vim.keymap.set("n", "[s", "[s", { desc = "Previous Spelling Error" })
vim.keymap.set("n", "z=", "z=", { desc = "Suggest Correction" })
-- e.g., in ~/.config/nvim/lua/config/keymaps.lua
local ls = require("luasnip")
vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })
