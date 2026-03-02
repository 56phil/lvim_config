return {
  "echasnovski/mini.misc",
  config = function()
    require("mini.misc").setup()
    vim.api.nvim_create_user_command("SpellToggle", function()
      vim.opt.spell = not vim.wo.spell
    end, {})
  end,
}
