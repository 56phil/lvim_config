-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>bw", ":write<CR>", { desc = "Write current buffer to DASD" })
vim.keymap.set("n", "<leader>bW", ":wall<CR>", { desc = "Write all buffers to DASD" })
vim.keymap.set("n", "<leader>bs", ":set spell!<CR>", { desc = "Toggle Spell Check" })
vim.keymap.set("n", "<leader>bc", ":RemoveContractions<CR>", { desc = "Remove contractions" })
vim.keymap.set("n", "<leader>ba", ":RemoveContractions all<CR>", { desc = "Remove contractions from all buffers" })
vim.keymap.set("n", "<leader>bx", ":write | bd<CR>", { desc = "Write current buffer to DASD & delete" })
vim.keymap.set("n", "<leader>bX", ":wall | q<CR>", { desc = "Write all buffers to DASD & quit" })
vim.keymap.set("n", "]s", "]s", { desc = "Next Spelling Error" })
vim.keymap.set("n", "[s", "[s", { desc = "Previous Spelling Error" })
vim.keymap.set("n", "z=", "z=", { desc = "Suggest Correction" })
local ok, writer = pcall(require, "writer")
if ok then
  vim.keymap.set("n", "<leader>tw", function()
    writer.reflow_paragraph(72)
  end, { desc = "Wrap paragraph (72)" })
  vim.keymap.set("v", "<leader>tw", function()
    writer.reflow_selection(72)
  end, { desc = "Wrap selection (72)" })
  vim.keymap.set("n", "<leader>tm", writer.toggle, { desc = "Toggle writer mode" })
  vim.keymap.set("n", "<leader>tb", function()
    writer.reflow_buffer(72)
  end, { desc = "Reflow entire buffer (72)" })
end
