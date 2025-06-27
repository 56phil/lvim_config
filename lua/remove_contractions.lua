local M = {}

local contractions = {
  ["I’m"] = "I am",
  ["aren’t"] = "are not",
  ["can’t"] = "cannot",
  ["didn’t"] = "did not",
  ["doesn’t"] = "does not",
  ["don’t"] = "do not",
  ["hadn’t"] = "had not",
  ["hasn’t"] = "has not",
  ["haven’t"] = "have not",
  ["he’s"] = "he is",
  ["isn’t"] = "is not",
  ["it’s"] = "it is",
  ["let’s"] = "let us",
  ["she’s"] = "she is",
  ["that’s"] = "that is",
  ["there’s"] = "there is",
  ["they’re"] = "they are",
  ["wasn’t"] = "was not",
  ["weren’t"] = "were not",
  ["we’re"] = "we are",
  ["what’s"] = "what is",
  ["who’s"] = "who is",
  ["won’t"] = "will not",
  ["you’re"] = "you are",
}

-- Helper function: process a single buffer
local function process_buffer(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  if not vim.bo[bufnr].modifiable then
    return
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if not name:match("%.tex$") then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false

  for i, line in ipairs(lines) do
    local original = line
    for from, to in pairs(contractions) do
      line = line:gsub(from, to)
    end
    if line ~= original then
      lines[i] = line
      modified = true
    end
  end

  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
end

-- Main entry point
function M.remove_contractions(opts)
  local target = opts.args or ""

  if target == "all" then
    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(bufs) do
      process_buffer(bufnr)
    end
    print("Contractions removed from all open .tex buffers.")
  else
    local bufnr = vim.api.nvim_get_current_buf()
    process_buffer(bufnr)
    print("Contractions removed from current buffer.")
  end
end

return M
