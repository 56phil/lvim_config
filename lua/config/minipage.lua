-- lua/config/minipage.lua
local M = {}

-- ===== Defaults =====
local DEFAULT_WIDTH = "0.85"
local DEFAULT_UNIT = "\\textwidth"

local function normalize_width(w)
  if not w or w == "" then
    return DEFAULT_WIDTH .. DEFAULT_UNIT
  end
  w = (w:gsub("%s+", "")) -- strip spaces

  -- If user already provided a unit (e.g., 8cm, 120pt, 0.6\textwidth), keep as-is
  if w:match("\\%a+") or w:match("%d%s*[%a]+$") then
    -- add leading backslash if they wrote 'textwidth' without it
    if w:match("^%d*%.?%d*textwidth$") then
      return w:gsub("textwidth$", DEFAULT_UNIT:sub(2))
    end
    return w
  end

  -- Bare number like 0.45 or .45 → assume \textwidth
  if w:match("^%d*%.?%d+$") then
    return w .. DEFAULT_UNIT
  end

  return w
end

-- ===== Core insertion function =====
local function insert_minipage(width)
  width = normalize_width(width)
  local bufnr = 0
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local lines = {
    "\\begin{minipage}{" .. width .. "}",
    "  ",
    "\\end{minipage}",
  }
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
  vim.api.nvim_win_set_cursor(0, { row + 2, 2 })
end

-- ===== Commands =====
pcall(vim.api.nvim_del_user_command, "Minipage")
pcall(vim.api.nvim_del_user_command, "MinipageDefault")
pcall(vim.api.nvim_del_user_command, "MinipageWrap")

vim.api.nvim_create_user_command("Minipage", function()
  local w = vim.fn.input("minipage width (default " .. DEFAULT_WIDTH .. DEFAULT_UNIT .. "): ")
  insert_minipage(w)
end, {})

vim.api.nvim_create_user_command("MinipageDefault", function()
  insert_minipage(DEFAULT_WIDTH .. DEFAULT_UNIT)
end, {})

vim.api.nvim_create_user_command("MinipageWrap", function()
  local w = vim.fn.input("minipage width (default " .. DEFAULT_WIDTH .. DEFAULT_UNIT .. "): ")
  w = normalize_width(w)
  local buf = 0
  local srow = vim.fn.getpos("'<")[2] - 1
  local erow = vim.fn.getpos("'>")[2]
  vim.api.nvim_buf_set_lines(buf, srow, srow, false, { "\\begin{minipage}{" .. w .. "}" })
  vim.api.nvim_buf_set_lines(buf, erow + 1, erow + 1, false, { "\\end{minipage}" })
end, {})

-- ===== Keymaps (buffer-local) =====
local aug = vim.api.nvim_create_augroup("MinipageHelper", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = { "tex", "plaintex", "latex" },
  callback = function(args)
    local opts = { buffer = args.buf, silent = true, noremap = true }
    -- Normal mode: insert default minipage
    vim.keymap.set(
      "n",
      "<leader>mp",
      ":MinipageDefault<CR>",
      vim.tbl_extend("force", opts, { desc = "Insert minipage" })
    )
    -- Visual mode: wrap selection
    vim.keymap.set(
      "v",
      "<leader>mw",
      ":<C-u>MinipageWrap<CR>",
      vim.tbl_extend("force", opts, { desc = "Wrap selection in minipage" })
    )
  end,
})

return M
