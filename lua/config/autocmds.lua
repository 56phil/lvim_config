-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-expand the "boiler" snippet in brand new Python files
-- Auto-expand the "boiler" LuaSnip snippet in brand-new Python files
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  callback = function(args)
    -- Only if truly empty buffer
    if vim.fn.line("$") ~= 1 or vim.fn.getline(1) ~= "" then
      return
    end

    -- Ensure LuaSnip plugin is loaded (LazyVim uses lazy.nvim)
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
      lazy.load({ plugins = { "LuaSnip" } })
    end

    -- Safe require after forcing load
    local ok_ls, ls = pcall(require, "luasnip")
    if not ok_ls then
      return
    end

    -- Find the "boiler" snippet for python
    local target
    for _, sn in ipairs(ls.get_snippets("python") or {}) do
      if sn.trigger == "boiler" then
        target = sn
        break
      end
    end
    if not target then
      return
    end

    -- Expand it
    ls.snip_expand(target)

    -- Optional: make the file executable if it already has a path
    local fname = vim.api.nvim_buf_get_name(args.buf)
    if fname ~= "" then
      local uv = vim.uv or vim.loop
      vim.schedule(function()
        pcall(uv.fs_chmod, fname, 493) -- 493 == 0o755
      end)
    end
  end,
})
