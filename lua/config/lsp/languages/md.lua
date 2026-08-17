return {
  {
    "marksman",
    lsp = {
      root_markers = { ".marksman.toml", ".git" },
      filetypes = { "markdown", "markdown.mdx" }
    }
  },
  {
    "markdown-preview.nvim",
    auto_enable = true,
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    wk = {
      { "<leader>p", group = "[p]review" },
      { "<leader>p_", hidden = true },
      { "<leader>pm", group = "[m]arkdown" },
      { "<leader>pm_", hidden = true }
    },
    keys = {
      {
        "<leader>pmp",
        "<cmd>MarkdownPreview <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview"
      },
      {
        "<leader>pms",
        "<cmd>MarkdownPreviewStop <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview stop"
      },
      {
        "<leader>pmt",
        "<cmd>MarkdownPreviewToggle <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview toggle"
      }
    },
    before = function()
      vim.g.mkdp_auto_close = 0
    end
  },
  {
    "markview.nvim",
    auto_enable = true,
    ft = "markdown",
    cmd = { "Markview" },
    after = function()
      require("markview").setup({})
    end
  }
}
