-- lua/writer.lua
local M = {}

-- Detect fenced code blocks (Markdown) and minted/lstlisting/verbatim (LaTeX-ish)
local function in_codeblock()
  local ft = vim.bo.filetype
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  if ft == "markdown" then
    local fence = 0
    for i = 1, row do
      if lines[i] and lines[i]:match("^%s*```") then
        fence = fence + 1
      end
    end
    return (fence % 2) == 1
  end

  if ft == "tex" or ft == "plaintex" or ft == "latex" then
    local env = 0
    for i = 1, row do
      local l = lines[i] or ""
      if
        l:match("\\begin%s*{%s*minted%s*}")
        or l:match("\\begin%s*{%s*lstlisting%s*}")
        or l:match("\\begin%s*{%s*verbatim%s*}")
      then
        env = env + 1
      elseif
        l:match("\\end%s*{%s*minted%s*}")
        or l:match("\\end%s*{%s*lstlisting%s*}")
        or l:match("\\end%s*{%s*verbatim%s*}")
      then
        env = math.max(0, env - 1)
      end
    end
    return env > 0
  end

  return false
end

local function line_starts_list(l)
  return l:match("^%s*[%-%*%+]%s+") or l:match("^%s*%d+[%.%)]%s+")
end

local function get_paragraph_range()
  -- Current paragraph boundaries using Vim motions:
  -- { jumps back a paragraph, } forward. We'll compute exact line range.
  local cur = vim.api.nvim_win_get_cursor(0)
  local start = cur[1]
  local finish = cur[1]

  -- expand up
  while start > 1 do
    local l = vim.fn.getline(start - 1)
    if l == "" then
      break
    end
    if line_starts_list(l) then
      break
    end
    start = start - 1
  end

  -- expand down
  local last = vim.fn.line("$")
  while finish < last do
    local l = vim.fn.getline(finish + 1)
    if l == "" then
      break
    end
    if line_starts_list(l) then
      break
    end
    finish = finish + 1
  end

  return start, finish
end

local function wrap_text(text, width)
  text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  local out, line = {}, ""
  for word in text:gmatch("%S+") do
    if line == "" then
      line = word
    elseif (#line + 1 + #word) > width then
      table.insert(out, line)
      line = word
    else
      line = line .. " " .. word
    end
  end
  if line ~= "" then
    table.insert(out, line)
  end
  return out
end

function M.reflow_paragraph(width)
  width = width or 72
  if in_codeblock() then
    return
  end

  local s, e = get_paragraph_range()
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)

  -- Keep indentation of first line
  local indent = (lines[1] or ""):match("^(%s*)") or ""
  -- Avoid reflowing obvious list items (leave them alone)
  if line_starts_list(lines[1] or "") then
    return
  end

  local joined = table.concat(lines, " ")
  local wrapped = wrap_text(joined, width)

  for i = 1, #wrapped do
    wrapped[i] = indent .. wrapped[i]
  end

  vim.api.nvim_buf_set_lines(0, s - 1, e, false, wrapped)
end

function M.reflow_selection(width)
  width = width or 72
  if in_codeblock() then
    return
  end

  local s = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)

  local indent = (lines[1] or ""):match("^(%s*)") or ""
  local joined = table.concat(lines, " ")
  local wrapped = wrap_text(joined, width)
  for i = 1, #wrapped do
    wrapped[i] = indent .. wrapped[i]
  end

  vim.api.nvim_buf_set_lines(0, s - 1, e, false, wrapped)
end

-- Writer mode: comfortable reading + consistent hard wrap target
function M.writer_on()
  vim.opt_local.textwidth = 72
  vim.opt_local.colorcolumn = "73"
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  vim.opt_local.showbreak = "↳ "
  vim.opt_local.spell = true
  vim.opt_local.spelllang = { "en_us" }
  vim.opt_local.formatoptions:append({ "tqn" }) -- allow gq, auto-wrap, numbered lists
  vim.opt_local.conceallevel = (vim.bo.filetype == "tex") and 0 or vim.opt_local.conceallevel:get()

  -- Center the text area a bit (works great on wide screens)
  vim.opt_local.sidescrolloff = 8
  vim.opt_local.scrolloff = 6
end

function M.writer_off()
  vim.opt_local.colorcolumn = ""
  vim.opt_local.wrap = false
  vim.opt_local.linebreak = false
  vim.opt_local.breakindent = false
  vim.opt_local.showbreak = ""
  vim.opt_local.spell = false
end

function M.toggle()
  if vim.b.writer_mode then
    vim.b.writer_mode = false
    M.writer_off()
  else
    vim.b.writer_mode = true
    M.writer_on()
  end
end

function M.reflow_buffer(width)
  width = width or 72

  local ft = vim.bo.filetype
  local fence_open = false
  local env_depth = 0

  local function is_md_fence(line)
    return line:match("^%s*```")
  end

  local function tex_begin(line)
    return line:match("\\begin%s*{%s*minted%s*}")
      or line:match("\\begin%s*{%s*lstlisting%s*}")
      or line:match("\\begin%s*{%s*verbatim%s*}")
  end

  local function tex_end(line)
    return line:match("\\end%s*{%s*minted%s*}")
      or line:match("\\end%s*{%s*lstlisting%s*}")
      or line:match("\\end%s*{%s*verbatim%s*}")
  end

  local function in_code_state(line)
    if ft == "markdown" then
      if is_md_fence(line) then
        fence_open = not fence_open
      end
      return fence_open
    end
    if ft == "tex" or ft == "plaintex" or ft == "latex" then
      if tex_begin(line) then
        env_depth = env_depth + 1
      end
      if tex_end(line) then
        env_depth = math.max(0, env_depth - 1)
      end
      return env_depth > 0
    end
    return false
  end

  local function is_blank(line)
    return line:match("^%s*$") ~= nil
  end
  local function starts_list(line)
    return line_starts_list(line)
  end -- uses your existing helper

  local save = vim.api.nvim_win_get_cursor(0)
  local bufnr = 0
  local lnum = 1
  local last = vim.api.nvim_buf_line_count(bufnr)

  -- Speed/UX tweaks while editing lots of lines
  local old_lz = vim.o.lazyredraw
  vim.o.lazyredraw = true

  while lnum <= last do
    local line = vim.fn.getline(lnum)

    -- Update code-block state *before* deciding to reflow.
    local in_code = in_code_state(line)

    if in_code or is_blank(line) or starts_list(line) then
      lnum = lnum + 1
    else
      -- Capture a paragraph: contiguous nonblank, non-list, non-code lines
      local p_start = lnum
      local p_end = lnum

      while p_end <= last do
        local l = vim.fn.getline(p_end)
        local code_here = in_code_state(l)

        if code_here or is_blank(l) or starts_list(l) then
          break
        end
        p_end = p_end + 1
      end
      p_end = p_end - 1

      local lines = vim.api.nvim_buf_get_lines(bufnr, p_start - 1, p_end, false)
      local indent = (lines[1] or ""):match("^(%s*)") or ""
      local joined = table.concat(lines, " ")
      local wrapped = wrap_text(joined, width)
      for i = 1, #wrapped do
        wrapped[i] = indent .. wrapped[i]
      end

      vim.api.nvim_buf_set_lines(bufnr, p_start - 1, p_end, false, wrapped)

      -- After replacement, continue after the paragraph we just wrote.
      lnum = p_start + #wrapped

      last = vim.api.nvim_buf_line_count(bufnr)
    end
  end

  vim.o.lazyredraw = old_lz
  vim.api.nvim_win_set_cursor(0, save)
end
return M
