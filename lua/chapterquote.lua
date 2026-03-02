-- ~/.config/nvim/lua/chapterquote.lua
local M = {}

local function read_delim(s, i, open, close)
  -- read a balanced {...} or [...] starting at s[i] == open
  assert(s:sub(i, i) == open, ("expected %s"):format(open))
  local depth, j = 0, i
  while j <= #s do
    local c = s:sub(j, j)
    if c == open then
      depth = depth + 1
    end
    if c == close then
      depth = depth - 1
      if depth == 0 then
        return s:sub(i + 1, j - 1), j + 1
      end
    end
    j = j + 1
  end
  return nil, i
end

local function skip_ws(s, i)
  local _, e = s:find("^%s*", i)
  return (e or i - 1) + 1
end

local function convert_once(s, from)
  local start_ = s:find([[\\chapterquote]], from, true)
  if not start_ then
    return s, false
  end
  local i = start_ + #"\\chapterquote"
  i = skip_ws(s, i)

  local author, source, quote

  -- Either [author] then {quote} ...
  if s:sub(i, i) == "[" then
    author, i = read_delim(s, i, "[", "]")
    i = skip_ws(s, i)
    if s:sub(i, i) ~= "{" then
      return s, false
    end
    quote, i = read_delim(s, i, "{", "}")
  -- ...or {quote}{author}{source?}
  elseif s:sub(i, i) == "{" then
    quote, i = read_delim(s, i, "{", "}")
    i = skip_ws(s, i)
    if s:sub(i, i) == "{" then
      author, i = read_delim(s, i, "{", "}")
      i = skip_ws(s, i)
      if s:sub(i, i) == "{" then
        source, i = read_delim(s, i, "{", "}")
      end
    end
  else
    return s, false
  end

  local after = i
  local attrib = author and ("\\hfill --- " .. author) or ""
  if source and #source > 0 then
    attrib = attrib .. " (\\emph{" .. source .. "})"
  end
  local block = ("\n\\begin{quote}\n%s\n\\end{quote}\n%s\n"):format(quote or "", attrib)

  local new_s = s:sub(1, start_ - 1) .. block .. s:sub(after)
  return new_s, true
end

local function convert_all(s)
  local changed = false
  local from = 1
  while true do
    local ns, did = convert_once(s, from)
    if not did then
      break
    end
    changed = true
    -- move past the block we just inserted to avoid re-matching
    from = #ns - (#s - from) -- approximate advance
    s = ns
  end
  return s, changed
end

function M.convert_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(lines, "\n")
  local out, changed = convert_all(text)
  if changed then
    local out_lines = {}
    for line in out:gmatch("([^\n]*)\n?") do
      table.insert(out_lines, line)
    end
    if out_lines[#out_lines] == "" then
      table.remove(out_lines, #out_lines)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out_lines)
    vim.notify("Converted \\chapterquote → quote", vim.log.levels.INFO)
  else
    vim.notify("No \\chapterquote found", vim.log.levels.WARN)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ChapterquoteToQuote", M.convert_buffer, {
    desc = "Convert \\chapterquote to quote",
  })
end

return M
