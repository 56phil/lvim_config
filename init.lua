-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local writer = require("writer")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "plaintex" },
  callback = function()
    require("writer").writer_on()
    vim.b.writer_mode = true
  end,
})

vim.keymap.set("n", "<leader>wc", function()
  -- Increase/decrease left padding via 'numberwidth' trick + signcolumn
  -- (Not perfect, but helps. Real centering is best with a plugin like zen-mode.)
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
end, { desc = "Writer clean view" })
