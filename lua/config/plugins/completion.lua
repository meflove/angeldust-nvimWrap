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
    "minuet-ai.nvim",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
    after = function(_)
      require("minuet").setup({
        provider = "claude",
        request_timeout = 2.5,
        throttle = 1500,
        debounce = 600,
        provider_options = {
          claude = {
            model = "glm-4.7",
            api_key = "ANTHROPIC_API_KEY",
            end_point = "https://api.z.ai/api/anthropic",
            optional = {},
            transform = {}
          }
        },
        virtualtext = {
          show_on_completion_menu = true
        }
      })
    end
  },
  {
    "colorful-menu.nvim",
    auto_enable = true,
    on_plugin = { "blink.cmp" }
  },
  {
    "blink.pairs",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
    after = function(_)
      require("blink.pairs").setup({
        mappings = {
          -- you can call require("blink.pairs.mappings").enable()
          -- and require("blink.pairs.mappings").disable()
          -- to enable/disable mappings at runtime
          enabled = true,
          cmdline = true,
          -- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
          -- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
          disabled_filetypes = {},
          wrap = {
            -- move closing pair via motion
            ["<C-b>"] = "motion",
            -- move opening pair via motion
            ["<C-S-b>"] = "motion_reverse"
            -- set to 'treesitter' or 'treesitter_reverse' to use treesitter instead of motions
            -- set to nil, '' or false to disable the mapping
            -- normal_mode = {} <- for normal mode mappings, only supports 'motion' and 'motion_reverse'
          },
          -- see the defaults:
          -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L52
          pairs = {}
        },
        highlights = {
          enabled = true,
          -- requires require('vim._core.ui2').enable({}), otherwise has no effect
          cmdline = true,
          -- set to { 'BlinkPairs' } to disable rainbow highlighting
          groups = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
          unmatched_group = "BlinkPairsUnmatched",

          -- highlights matching pairs under the cursor
          matchparen = {
            enabled = true,
            -- known issue where typing won't update matchparen highlight, disabled by default
            cmdline = false,
            -- also include pairs not on top of the cursor, but surrounding the cursor
            include_surrounding = false,
            group = "BlinkPairsMatchParen",
            priority = 250
          }
        }
      })
    end
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require("blink.cmp").setup({
        keymap = {
          preset = "super-tab",
          -- Manually invoke minuet completion.
          ["<A-y>"] = require("minuet").make_blink_map()
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
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
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
          default = { "lazydev", "lsp", "path", "snippets", "buffer", "omni", "minuet" },
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
            },
            minuet = {
              name = "minuet",
              module = "minuet.blink",
              async = true,
              timeout_ms = 7500,
              score_offset = 50
            }
          }
        }
      })
    end
  }
}
