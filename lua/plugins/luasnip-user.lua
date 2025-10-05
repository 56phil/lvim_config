return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    opts = {},
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.set_config(opts or {})

      -- Load YOUR Lua snippets (this is your tex.lua)
      require("luasnip.loaders.from_lua").lazy_load({
        paths = {
          vim.fn.stdpath("config") .. "/snippets",
          vim.fn.stdpath("config") .. "/LuaSnip/snippets",
        },
      })

      -- If VSCode-style snippets are present, load them but exclude LaTeX
      pcall(function()
        require("luasnip.loaders.from_vscode").lazy_load({
          exclude = { "latex" }, -- prevents the problematic regex-transform snippet
        })
      end)
    end,
  },
}
