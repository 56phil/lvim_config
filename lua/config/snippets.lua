-- Only set if not already provided by LazyVim/cmp
if not (vim.snippet and vim.snippet.expand) then
  vim.snippet = vim.snippet or {}
  vim.snippet.expand = function(body)
    require("luasnip").lsp_expand(body)
  end
end
