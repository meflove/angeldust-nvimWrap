local root_markers = { ".git", ".jj" }
local filetypes = { "nu" }

vim.filetype.add({
  extension = {
    nuon = "nu"
  }
})

return {
  {
    "nu-lint",
    lsp = {
      root_markers = root_markers,
      filetypes = filetypes,
      cmd = { "nu-lint", "--lsp" },
      settings = {
        ["nu-lint"] = {}
      }
    }
  },
  {
    "nushell",
    lsp = {
      root_markers = root_markers,
      filetypes = filetypes,
      settings = {
        nushell = {}
      }
    }
  }
}
