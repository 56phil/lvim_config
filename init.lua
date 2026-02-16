-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("chapterquote").setup()
require("config.minipage")
require("config.chapterquote")

vim.api.nvim_create_user_command("RemoveContractions", function(opts)
  require("remove_contractions").remove_contractions(opts)
end, {
  nargs = "?",
  complete = function()
    return { "all" }
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  command = "0r ~/.config/nvim/templates/skeleton.py",
})

vim.g.vimtex_compiler_enabled = 0
vim.api.nvim_set_hl(0, "StatusLineSpecial", { fg = "#ffffff", bg = "#aa0000", bold = true })
vim.o.statusline = "%#StatusLineSpecial#%{&buftype!='' ? '['.&buftype.'] ' : ''}%#StatusLine#%f %m %r %= %l:%c"

-- Add "% filename.tex" to empty .tex files on open
-- (LuaLS lint fix only; Neovim runtime is fine)
---@diagnostic disable: undefined-global

local grp = vim.api.nvim_create_augroup("TexSkeletonOnEmpty", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  group = grp,
  pattern = "*.tex",
  callback = function(ev)
    local buf = ev.buf
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return end

    -- Only act if file is truly empty on disk (or doesn't exist yet) AND buffer is empty
    local stat = vim.loop.fs_stat(name)
    local disk_empty = (stat == nil) or (stat.size == 0)

    local line_count = vim.api.nvim_buf_line_count(buf)
    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    local buf_empty = (line_count == 1 and first == "")

    if not (disk_empty and buf_empty) then return end

    local fname = vim.fn.fnamemodify(name, ":t")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "% " .. fname,
      "\\cleardoublepage{}",
      "",
      "\\chapter{}",
      "",
    })

    -- place cursor inside the {}
    vim.api.nvim_win_set_cursor(0, { 4, 9 }) -- line 4, col after '{' (0-based col)
  end,
})

