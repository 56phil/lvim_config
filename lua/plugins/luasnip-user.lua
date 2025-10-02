return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    opts = {},
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.set_config(opts or {})
      require("luasnip.loaders.from_lua").lazy_load({
        paths = {
          -- vim.fn.stdpath("config") .. "/snippets",
          vim.fn.stdpath("config") .. "/LuaSnip/snippets",
        },
      })
    end,
  },
}
