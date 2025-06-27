-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.api.nvim_create_user_command("RemoveContractions", function(opts)
  require("remove_contractions").remove_contractions(opts)
end, {
  nargs = "?",
  complete = function()
    return { "all" }
  end,
})
