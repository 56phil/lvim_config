return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    local ls = require("luasnip")
    opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
      ["<C-k>"] = cmp.mapping(function(fallback)
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-j>"] = cmp.mapping(function(fallback)
        if ls.jumpable(-1) then
          ls.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    })
    opts.snippet = {
      expand = function(a)
        require("luasnip").lsp_expand(a.body)
      end,
    }
    return opts
  end,
}
