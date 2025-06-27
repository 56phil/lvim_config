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
              onSave = true,
              forwardSearchAfter = false,
            },
            forwardSearch = {
              executable = "zathura", -- replace if using another PDF viewer
              args = { "--synctex-forward", "%l:1:%f", "%p" },
            },
            chktex = {
              onEdit = false,
              onOpenAndSave = false,
            },
          },
        },
      },
    },

    setup = {
      texlab = function(_, _)
        local default_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
          if result and result.diagnostics then
            result.diagnostics = vim.tbl_filter(function(diagnostic)
              return not diagnostic.message:match("fontspec")
            end, result.diagnostics)
          end
          default_handler(err, result, ctx, config)
        end
      end,
    },
  },
}
