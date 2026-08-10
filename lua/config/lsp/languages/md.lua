return {
  {
    "marksman",
    root_markers = { ".marksman.toml", ".git" },
    lsp = {
      filetypes = { "markdown", "markdown.mdx" },
    },
  },
  {
    "markdown-preview.nvim",
    auto_enable = true,
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreview <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview",
      },
      {
        "<leader>ms",
        "<cmd>MarkdownPreviewStop <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview stop",
      },
      {
        "<leader>mt",
        "<cmd>MarkdownPreviewToggle <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview toggle",
      },
    },
    before = function()
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "markview.nvim",
    auto_enable = true,
    ft = "markdown",
    cmd = { "Markview" },
    after = function()
      require("markview").setup({})
    end,
  },
}
