return {
  name = "epigraph-to-quote",
  dir = vim.fn.stdpath("config") .. "/lua/epigraph_to_quote",
  lazy = false,
  config = function()
    vim.api.nvim_create_user_command("ConvertEpigraph", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local result = {}
      local i = 1

      while i <= #lines do
        local line = lines[i]

        -- Handle multi-line \epigraph{...}{...}
        if line:match("\\epigraph{") and not line:match("}{") then
          local buffer = line
          i = i + 1
          while i <= #lines and not buffer:match("}{") do
            buffer = buffer .. " " .. lines[i]
            i = i + 1
          end
          local quote, author = buffer:match("\\epigraph{(.-)}{(.-)}")
          if quote and author then
            table.insert(result, "\\begin{quote}")
            table.insert(result, "\\itshape")
            table.insert(result, string.format("\"%s\"\\\\", quote))
            table.insert(result, string.format("— %s", author))
            table.insert(result, "\\end{quote}")
          else
            table.insert(result, buffer)
          end

        -- Handle single-line epigraphs
        elseif line:match("\\epigraph{.-}{.-}") then
          local quote, author = line:match("\\epigraph{(.-)}{(.-)}")
          if quote and author then
            table.insert(result, "\\begin{quote}")
            table.insert(result, "\\itshape")
            table.insert(result, string.format("\"%s\"\\\\", quote))
            table.insert(result, string.format("— %s", author))
            table.insert(result, "\\end{quote}")
          else
            table.insert(result, line)
          end
          i = i + 1

        -- All other lines pass through unchanged
        else
          table.insert(result, line)
          i = i + 1
        end
      end

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
      print("All \\epigraph blocks converted to quote environments.")
    end, {})
  end,
}
