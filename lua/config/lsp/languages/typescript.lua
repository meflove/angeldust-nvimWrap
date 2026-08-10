return {
  {
    "typescript-tools.nvim",
    auto_enable = true,
    ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    after = function()
      require("typescript-tools").setup({
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" }
          }
        }
      })
    end
  }
}
