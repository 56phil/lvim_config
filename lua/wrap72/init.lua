local M = {}

-- Simple word-wrap at column 72
local function wrap_text()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local wrapped = {}
  local linebuf = ""

  for _, line in ipairs(lines) do
    -- Preserve empty lines
    if line:match("^%s*$") then
      table.insert(wrapped, "")
      linebuf = ""
      goto continue
    end

    for word in line:gmatch("%S+") do
      if #linebuf + #word + 1 > 72 then
        table.insert(wrapped, linebuf)
        linebuf = word
      else
        if linebuf == "" then
          linebuf = word
        else
          linebuf = linebuf .. " " .. word
        end
      end
    end

    if linebuf ~= "" then
      table.insert(wrapped, linebuf)
      linebuf = ""
    end

    ::continue::
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, wrapped)
end

function M.setup()
  vim.api.nvim_create_user_command("Wrap72", wrap_text, {})
end

return M
