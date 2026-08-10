-- nvim-lint setup. runtime deps (yamllint, statix, demjson3, eslint_d, clangtidy, ...)
-- are provided by config.specs.lint.runtimePkgs in module.nix.
nixInfo.lze.load({
  {
    "nvim-lint",
    auto_enable = true,
    event = "FileType",
    after = function()
      vim.env.ESLINT_D_PPID = vim.fn.getpid()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        nix = { "statix" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        cpp = { "clangtidy" },
        c = { "clangtidy" }
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end
      })
    end
  }
})
