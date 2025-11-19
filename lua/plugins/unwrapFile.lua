-- lua/plugins/unwrap.lua
-- Adds :Unwrap and :Wrap72 commands + keymaps

return {
  {
    -- just hang our config off LazyVim itself
    "LazyVim/LazyVim",
    lazy = false,
    config = function()
      -- Unwrap: join paragraphs into single lines, keeping blank lines
      local function unwrap_buffer()
        local bufnr = 0
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local new = {}
        local acc = nil

        local function flush()
          if acc ~= nil then
            table.insert(new, acc)
            acc = nil
          end
        end

        for _, line in ipairs(lines) do
          if line:match("^%s*$") then
            -- blank line: end of paragraph
            flush()
            table.insert(new, line)
          else
            -- nonblank: accumulate into current paragraph
            local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
            if acc == nil then
              acc = trimmed
            else
              acc = acc .. " " .. trimmed
            end
          end
        end

        flush()
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new)
      end

      -- Wrap72: wrap paragraphs to 72 cols using Vim's internal formatter
      local function wrap72_buffer()
        local old_tw = vim.bo.textwidth
        local old_fe = vim.bo.formatexpr

        vim.bo.textwidth = 72
        vim.bo.formatexpr = "" -- force built-in formatter
        vim.cmd("normal! gggqG") -- format whole buffer

        vim.bo.textwidth = old_tw
        vim.bo.formatexpr = old_fe
      end

      -- User commands
      vim.api.nvim_create_user_command("Unwrap", unwrap_buffer, {})
      vim.api.nvim_create_user_command("Wrap72", wrap72_buffer, {})

      -- Keymaps
      -- You chose <leader>uW for unwrap:
      vim.keymap.set("n", "<leader>uW", "<cmd>Unwrap<CR>", { desc = "Unwrap buffer" })
      -- And a wrap key; tweak if you like:
      vim.keymap.set("n", "<leader>w7", "<cmd>Wrap72<CR>", { desc = "Wrap buffer to 72 cols" })
    end,
  },
}
