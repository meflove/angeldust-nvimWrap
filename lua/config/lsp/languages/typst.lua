return {
  {
    "tinymist",
    lsp = {
      filetypes = { "typst" },
      settings = {
        tinymist = {
          compileStatus = true,
          completion = { triggerOnSnippetPlaceholders = true },
          lint = {
            enabled = true,
            when = "onType"
          }
        }
      }
    }
  },
  {
    "typst-preview.nvim",
    auto_enable = true,
    ft = { "typst" },
    wk = {
      { "<leader>p", group = "[p]review" },
      { "<leader>p_", hidden = true },
      { "<leader>pt", group = "[t]ypst" },
      { "<leader>pt_", hidden = true }
    },
    keys = {
      {
        "<leader>ptp",
        "<cmd>TypstPreview <CR>",
        mode = { "n" },
        noremap = true,
        desc = "typst preview"
      },
      {
        "<leader>pts",
        "<cmd>TypstPreviewStop <CR>",
        mode = { "n" },
        noremap = true,
        desc = "typst preview stop"
      },
      {
        "<leader>ptt",
        "<cmd>TypstPreviewToggle <CR>",
        mode = { "n" },
        noremap = true,
        desc = "typst preview toggle"
      }
    },
    after = function()
      require("typst-preview").setup({
        invert_colors = "auto"
      })
    end
  }
}
