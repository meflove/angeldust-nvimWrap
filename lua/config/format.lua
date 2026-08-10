-- conform.nvim setup. runtime deps (alejandra, emmylua_formatter, ruff, shfmt, yamlfmt,
-- fixjson, prettierd, clang-format, ...) are provided by config.specs.*.runtimePkgs.
nixInfo.lze.load({
  {
    "conform.nvim",
    auto_enable = true,
    event = "BufWritePre",
    after = function()
      local conform = require("conform")

      -- luafmt from conform doesn't work
      conform.formatters.luafmt = { command = nixInfo("luafmt", "info", "emmylua_formatter_path") }

      conform.setup({
        formatters_by_ft = {
          lua = { "luafmt" },
          python = { "ruff_format", "ruff_organize_imports" },
          nix = { "alejandra" },
          sh = { "shfmt" },
          yaml = { "yamlfmt", "yamlfix" },
          json = { "json_repair", "fixjson" },
          html = { "prettierd" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          markdown = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          cpp = { "clang-format" },
          rust = { "rustfmt", lsp_format = "fallback" },
          c = { "clang-format" },
          ["*"] = { "trim_whitespace" }
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback"
        }
      })
    end
  }
})
