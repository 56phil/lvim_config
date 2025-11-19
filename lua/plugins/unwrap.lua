vim.keymap.set("n", "<leader>tw", function()
  if vim.bo.textwidth == 0 then
    vim.bo.textwidth = 72
    print("textwidth = 72 (wrapping on)")
  else
    vim.bo.textwidth = 0
    print("textwidth = 0 (wrapping off / unwrap mode)")
  end
end)
