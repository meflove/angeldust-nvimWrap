return {
  {
    "nu-lint",
    lsp = {
      root_markers = { ".git" },
      filetypes = { "nu" },
      cmd = { "nu-lint", "--lsp" },
      settings = {}
    }
  }
}
