-- plugin/wrap72.lua
-- Reflow buffer so no line exceeds a given width (default: 72)
-- ~/.config/nvim/lua/plugins/wrap72.lua
return {
  {
    name = "wrap72",
    -- point Lazy at your local plugin folder
    dir = vim.fn.stdpath("config") .. "/lua/wrap72",
    config = function()
      require("wrap72").setup()
    end,
  },
}
