-- conform.nvim setup. runtime deps (alejandra, emmylua_formatter, ruff, shfmt, yamlfmt,
-- fixjson, prettierd, clang-format, ...) are provided by config.specs.*.runtimePkgs.
return {
  {
    "conform.nvim",
    auto_enable = true,
    event = "BufWritePre",
    after = function()
      local conform = require("conform")

      conform.formatters = {
        -- luafmt from conform doesn't work
        luafmt = {
          command = nixInfo("luafmt", "info", "emmylua_formatter_path")
        },
        -- for formatting nuon files
        nufmt = {
          args = { "--stdin" },
          stdin = true
        }
      }

      conform.setup({
        formatters_by_ft = {
          lua = { "luafmt" },
          python = { "ruff_format", "ruff_organize_imports" },
          nix = { "alejandra" },
          sh = { "shfmt" },
          nu = { "nufmt" },
          yaml = { "yamlfmt", "yamlfix" },
          json = { "json_repair", "fixjson" },
          kdl = { "kdlfmt" },
          html = { "prettierd" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          markdown = { "prettierd" },
          typst = { "typstyle", lsp_format = "prefer" },
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
}
