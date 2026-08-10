return {
  {
    "bacon-ls",
    before = function()
      vim.diagnostic.config({ update_in_insert = true })
    end,
    lsp = {
      init_options = {
        cargo = { updateOnInsert = true }
      },
      filetypes = { "rust" },
      settings = {
        bacon_ls = {
          backend = "cargo",
          cargo = {
            command = "clippy",
            checkOnSave = true
          }
        }
      }
    }
  },
  {
    "rustowl",
    auto_enable = true,
    ft = { "rust" },
    lazy = false,
    after = function()
      require("rustowl").setup({
        auto_enable = true,
        idle_time = 300,
        client = {
          on_attach = function(_, buffer)
            vim.keymap.set("n", "<leader>ro", function()
              require("rustowl").toggle(buffer)
            end, { buffer = buffer, desc = "Toggle RustOwl" }
            )

            vim.keymap.set("n", "<leader>re", function()
              require("rustowl").enable(buffer)
            end, { buffer = buffer, desc = "Enable RustOwl" }
            )

            vim.keymap.set("n", "<leader>rd", function()
              require("rustowl").disable(buffer)
            end, { buffer = buffer, desc = "Disable RustOwl" }
            )
          end
        }
      })
    end
  },
  {
    "rustaceanvim",
    auto_enable = true,
    ft = { "rust" },
    lazy = false,
    init = function()
      vim.g.rustaceanvim.server = {
        on_attach = function(bufnr)
          vim.keymap.set(
            "n", "<leader>a",
            function()
              vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
              -- or vim.lsp.buf.codeAction() if you don't want grouping.
            end,
            {
              silent = true,
              buffer = bufnr
            }
          )
          vim.keymap.set(
            "n",
            "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
            function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end,
            { silent = true, buffer = bufnr }
          )
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true
              }
            },
            checkOnSave = false,
            diagnostics = {
              enable = false
            },
            procMacro = {
              enable = true
            },
            files = {
              exclude = {
                ".direnv",
                ".git",
                ".jj",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv"
              },
              -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
              watcher = "client"
            }
          }
        }
      }
    end
  },
  {
    "crates.nvim",
    auto_enable = true,
    event = { "BufRead Cargo.toml" },
    after = function()
      require("crates").setup({
        completion = {
          crates = {
            enabled = true
          }
        },
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true
        }
      })

      -- Buffer-local keymaps, scoped exclusively to Cargo.toml buffers.
      local crates = require("crates")
      local apply_crates_keymaps = function(bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            silent = true,
            desc = "Crates: " .. desc
          })
        end

        -- UI
        map("n", "<leader>ct", crates.toggle, "[T]oggle virtual text")
        map("n", "<leader>cr", crates.reload, "[R]eload from crates.io")

        -- Popups
        map("n", "<leader>cv", crates.show_versions_popup, "show [V]ersions")
        map("n", "<leader>cf", crates.show_features_popup, "show [F]eatures")
        map("n", "<leader>cd", crates.show_dependencies_popup, "show [D]ependencies")

        -- Upgrade (to newest version)
        map("n", "<leader>cU", crates.upgrade_crate, "upgrade crate (line)")
        map("v", "<leader>cU", crates.upgrade_crates, "upgrade crates (selection)")
        map("n", "<leader>cA", crates.upgrade_all_crates, "upgrade [A]ll crates")

        -- Transformations
        map("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, "e[X]pand to inline table")
        map("n", "<leader>cX", crates.extract_crate_into_table, "e[X]tract into table")

        -- External links
        map("n", "<leader>cH", crates.open_homepage, "open [H]omepage")
        map("n", "<leader>cR", crates.open_repository, "open [R]epository")
        map("n", "<leader>cD", crates.open_documentation, "open docs.rs ([D]ocs)")
        map("n", "<leader>cC", crates.open_crates_io, "open [C]rates.io")
        map("n", "<leader>cL", crates.open_lib_rs, "open [L]ib.rs")
      end

      -- Apply to the Cargo.toml that triggered this plugin to lazy-load ...
      local cur = vim.api.nvim_get_current_buf()
      if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(cur), ":t") == "Cargo.toml" then
        apply_crates_keymaps(cur)
      end

      -- ... and to every Cargo.toml opened afterwards.
      local group = vim.api.nvim_create_augroup("crates_keymaps", { clear = true })
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "Cargo.toml",
        group = group,
        callback = function(args)
          apply_crates_keymaps(args.buf)
        end
      })
    end
  },
  {
    "taplo",
    lsp = {
      filetypes = { "toml" },
      settings = {
        taplo = {}
      }
    }
  }
}
