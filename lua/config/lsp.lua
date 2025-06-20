require("lspconfig").texlab.setup({
  settings = {
    texlab = {
      build = {
        executable = "xelatex",
        args = { "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = true,
      },
      forwardSearch = {
        executable = "zathura", -- or Skim, or whatever PDF viewer you use
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
    },
  },
})
