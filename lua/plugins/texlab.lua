return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      texlab = {
        settings = {
          texlab = {
            build = {
              executable = "xelatex",
              args = { "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = false,
              forwardSearchAfter = false,
            },
            forwardSearch = {
              executable = "zathura", -- change if needed
              args = { "--synctex-forward", "%l:1:%f", "%p" },
            },
          },
        },
      },
    },
  },
}
