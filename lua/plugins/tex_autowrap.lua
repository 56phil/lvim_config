return {
  {
    -- No external plugin; just our autocmd
    "nvim-lua/plenary.nvim", -- safe dummy dependency so LazyVim loads the file
    ft = "tex",
    config = function()
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.tex",
        callback = function()
          -- Run your custom wrapping command if it exists
          if vim.fn.exists(":Wrap72") == 2 then
            vim.cmd("silent Wrap72")
          else
            -- Fallback: use built-in text formatting
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.cmd("silent normal! gggqG")
            vim.api.nvim_win_set_cursor(0, cursor)
          end
        end,
      })
    end,
  },
}
