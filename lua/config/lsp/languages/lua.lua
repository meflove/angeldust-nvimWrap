return {
  {
    -- lazydev makes the lua lsp load only the relevant definitions for a file,
    -- and lets us correlate the `nixInfo` global with the lze/lzextras type files.
    "lazydev.nvim",
    auto_enable = true,
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require("lazydev").setup({
        library = {
          -- load lze + lzextras lua type defs wherever `nixInfo.lze` is referenced
          { words = { "nixInfo" }, path = nixInfo("", "info_plugin_path") .. '/lua' },
          { words = { "nixInfo%.lze" }, path = nixInfo("lze", "plugins", "start", "lze") .. '/lua' },
          { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. '/lua' }
        }
      })
    end
  },
  {
    "emmylua_ls",
    lsp = {
      filetypes = { "lua" },
      root_markers = {
        ".emmyrc.json",
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
        ".jj"
      },
      settings = {
        emmylua = {
          runtime = {
            version = "LuaJIT"
          },
          workspace = {
            checkThirdParty = false,
            -- Or pull in all of 'runtimepath'.
            -- NOTE: this is a lot slower and will cause issues when working on
            -- your own configuration.
            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true)
          },
          formatters = {
            ignoreComments = true
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixInfo", "vim" }
          },
          telemetry = { enabled = false }
        }
      }
    }
  }
}
