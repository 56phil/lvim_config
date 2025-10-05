
-- lua/config/chapterquote.lua
-- Expand every \chapterquote[...] {text} in the current buffer into a centered minipage block.

local M = {}

-- --- utilities --------------------------------------------------------------

-- Return content inside a balanced pair (supports nesting for { } ), starting
-- at index `i` which must point AT the opening char. Returns (content, next_i).
local function parse_balanced(s, i, open, close, allow_nest)
  if i > #s or s:sub(i, i) ~= open then return nil, i end
  local depth, j = 0, i
  j = j + 1 -- skip first open
  depth = 1
  local out = {}
  while j <= #s do
    local ch = s:sub(j, j)
    if allow_nest and ch == open then
      depth = depth + 1
      out[#out + 1] = ch
      j = j + 1
    elseif ch == close then
      depth = depth - 1
      if depth == 0 then
        return table.concat(out), j + 1
      end
      out[#out + 1] = ch
      j = j + 1
    else
      out[#out + 1] = ch
      j = j + 1
    end
  end
  return nil, i -- unbalanced; give up
end

-- Trim just spaces/tabs/newlines at ends.
local function trim(str)
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Wrap quote with typographic quotes if it doesn't look already quoted.
local function add_quotes_if_needed(txt)
  local t = trim(txt)
  if t:match('^“') or t:match("^``") or t:match('^"') then
    return txt
  end
  -- Use curly quotes for looks; change to `` '' if you prefer pure TeX.
  return "“" .. t .. "”"
end

-- Build the replacement LaTeX block.
local function build_block(author, quote, width)
  author = author and trim(author) or ""
  quote  = add_quotes_if_needed(quote)
  width  = width or "0.67\\textwidth"

  local author_block = ""
  if author ~= "" then
    author_block = "\n  \\raggedleft — " .. author .. "\\par"
  end

  return table.concat({
    "\\begin{center}",
    "\\begin{minipage}{" .. width .. "}",
    "{\\small",
    "\\begin{center}",
    quote,
    "\\end{center}",
    "}" .. author_block,
    "\\end{minipage}",
    "\\end{center}",
  }, "\n")
end

-- --- main worker ------------------------------------------------------------

local function expand_all_chapterquotes(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(lines, "\n")

  local out, i, changed = {}, 1, false
  while i <= #text do
    local s, e = text:find("\\chapterquote", i, true)
    if not s then
      out[#out + 1] = text:sub(i)
      break
    end

    -- copy chunk before match
    out[#out + 1] = text:sub(i, s - 1)

    local j = e + 1

    -- optional [author]
    local author = nil
    while j <= #text and text:sub(j, j):match("%s") do j = j + 1 end
    if j <= #text and text:sub(j, j) == "[" then
      author, j = parse_balanced(text, j, "[", "]", false)
      if not author then
        -- give up on this occurrence; copy literal and continue
        out[#out + 1] = text:sub(s, j)
        i = j
        goto continue
      end
    end

    -- required {quote} (allow nested braces)
    while j <= #text and text:sub(j, j):match("%s") do j = j + 1 end
    if j > #text or text:sub(j, j) ~= "{" then
      -- malformed; copy literal and continue
      out[#out + 1] = text:sub(s, j)
      i = j
      goto continue
    end
    local quote
    quote, j = parse_balanced(text, j, "{", "}", true)
    if not quote then
      out[#out + 1] = text:sub(s, j)
      i = j
      goto continue
    end

    -- produce replacement block
    out[#out + 1] = build_block(author, quote, "0.67\\textwidth")
    changed = true
    i = j
    ::continue::
  end

  if changed then
    local new_text = table.concat(out)
    local new_lines = {}
    for line in (new_text .. "\n"):gmatch("([^\n]*)\n") do
      table.insert(new_lines, line)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  else
    vim.notify("No \\chapterquote commands found.", vim.log.levels.INFO)
  end
end

-- --- commands & keymaps -----------------------------------------------------

-- Redefine safely
pcall(vim.api.nvim_del_user_command, "ChapterquoteExpand")
vim.api.nvim_create_user_command("ChapterquoteExpand", function()
  expand_all_chapterquotes(0)
end, {})

-- TeX-only keymap: <leader>cq
local aug = vim.api.nvim_create_augroup("ChapterquoteHelper", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = { "tex", "plaintex", "latex" },
  callback = function(args)
    vim.keymap.set(
      "n",
      "<leader>cq",
      ":ChapterquoteExpand<CR>",
      { buffer = args.buf, silent = true, noremap = true, desc = "Expand \\chapterquote commands" }
    )
  end,
})

return M
