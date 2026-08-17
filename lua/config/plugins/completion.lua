local load_w_after = function(name)
  vim.cmd.packadd(name)
  vim.cmd.packadd(name .. "/after")
end

return {
  {
    "cmp-cmdline",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
    load = load_w_after
  },
  {
    "blink.compat",
    auto_enable = true,
    dep_of = { "cmp-cmdline" }
  },
  {
    "luasnip",
    auto_enable = true,
    dep_of = { "blink.cmp" },
    after = function(_)
      local ls = require("luasnip")
      local types = require("luasnip.util.types")

      ls.setup({
        -- Allow jumping back to a previous tab-stop with <S-Tab>.
        history = true,
        -- Re-evaluate function/dynamic nodes as you type (powers the `up` snippet).
        update_events = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { "● choiceNode — cycle with <C-l>", "Comment" } }
            }
          }
        }
      })

      -- Load lua-format snippets from `lua/config/snippets/<ft>.lua`.
      local snippet_paths = vim.api.nvim_get_runtime_file("lua/config/snippets", true)
      if #snippet_paths > 0 then
        require("luasnip.loaders.from_lua").lazy_load({ paths = snippet_paths })
      end

      -- Cycle choice nodes. blink.cmp's super-tab preset handles <Tab>/<S-Tab>
      -- snippet jumping, so we only add choice cycling here.
      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "LuaSnip: next choice node" }
      )
      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.choice_active() then
          ls.change_choice(-1)
        end
      end, { silent = true, desc = "LuaSnip: previous choice node" }
      )
    end
  },
  {
    "colorful-menu.nvim",
    auto_enable = true,
    on_plugin = { "blink.cmp" }
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      local lazydev_installed = nixInfo.utils.get_nix_plugin_path("lazydev.nvim") ~= nil

      require("blink.cmp").setup({
        keymap = {
          preset = "super-tab"
        },
        fuzzy = {
          implementation = "prefer_rust_with_warning",
          sorts = {
            "exact",
            "score",
            "sort_text"
          }
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true
            }
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            if type == "/" or type == "?" then
              return { "buffer" }
            end
            if type == ":" or type == "@" then
              return { "cmdline", "cmp_cmdline" }
            end
            return {}
          end
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true
          }
        },
        completion = {
          ghost_text = { enabled = true, show_with_menu = true },
          accept = {
            create_undo_point = true,
            auto_brackets = {
              enabled = true,
              default_brackets = { "(", ")" },
              kind_resolution = {
                enabled = true,
                blocked_filetypes = { "typescriptreact", "javascriptreact", "vue" }
              }
            }
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
              columns = { { "kind_icon" }, { "label", gap = 1 } },
              components = {
                label = {
                  text = function(ctx)
                    local ok, cm = pcall(require, "colorful-menu")
                    if ok then
                      return cm.blink_components_text(ctx)
                    end
                    return ctx.label
                  end,
                  highlight = function(ctx)
                    local ok, cm = pcall(require, "colorful-menu")
                    if ok then
                      return cm.blink_components_highlight(ctx)
                    end
                    return nil
                  end
                }
              }
            }
          }
        },
        snippets = {
          preset = "luasnip"
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          -- lazydev only exists for lua files (and only if the `lua` spec is
          -- enabled), so it must not be resolved in every other filetype.
          per_filetype = lazydev_installed and { lua = { "lazydev", "lsp", "path", "snippets", "buffer" } } or {},
          providers = {
            path = { score_offset = 50 },
            lsp = { score_offset = 40 },
            snippets = { score_offset = 40 },
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100
            },
            cmp_cmdline = {
              name = "cmp_cmdline",
              module = "blink.compat.source",
              score_offset = -100,
              opts = { cmp_name = "cmdline" }
            }
          }
        }
      })
    end
  }
}
