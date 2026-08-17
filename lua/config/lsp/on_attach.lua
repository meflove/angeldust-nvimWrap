-- Global on_attach shared by every LSP. Wired in via vim.lsp.config('*', { on_attach = ... }).
return function(client, bufnr)
  -- helper for buffer-local keymaps with an "LSP: " desc prefix
  local map = function(keys, func, desc, mode)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set(mode or 'n', keys, func, { buffer = bufnr, desc = desc })
  end

  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

  -- See `:help K` for why this keymap
  map("K", vim.lsp.buf.hover, "Hover Documentation")
  map("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  map("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders"
  )

  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ lsp_format = "fallback" })
    else
      vim.lsp.buf.format()
    end
  end, { desc = "Format current buffer" }
  )

  if client and client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references
    })
  end
end
