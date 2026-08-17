return {
  {
    "mini.icons",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("mini.icons").setup()
    end
  },
  {
    "indent-blankline.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    load = function(name)
      -- rainbow-delimiters is configured together with ibl, so packadd it here
      vim.cmd.packadd("rainbow-delimiters.nvim")
      vim.cmd.packadd(name)
    end,
    after = function()
      local highlight = {
        "RainbowRed", "RainbowYellow", "RainbowBlue", "RainbowOrange", "RainbowGreen", "RainbowViolet", "RainbowCyan"
      }
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      vim.g.rainbow_delimiters = { highlight = highlight }
      require("ibl").setup { indent = { highlight = highlight } }

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      local lib = require("rainbow-delimiters.lib")
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          lib.attach(buf)
        end
      end
    end
  },
  {
    "neural-open",
    auto_enable = true,
    lazy = false,
    keys = {
      { "<leader><leader>", "<Plug>(NeuralOpen)", desc = "Neural Open Files" }
    }
  },
  {
    "snacks.nvim",
    auto_enable = true,
    dep_of = { "neural-open" },
    lazy = false,
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer"
      },
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "Toggle Snacks Explorer"
      },
      {
        "<leader>E",
        function()
          local explorer_pickers = Snacks.picker.get({ source = "explorer" })
          if #explorer_pickers == 0 then
            Snacks.picker.explorer()
          else
            explorer_pickers[1]:focus()
          end
        end,
        desc = "Focus Snacks Explorer"
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep"
      },
      {
        "<leader>ss",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Symbols"
      },
      {
        "<leader>su",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo History"
      }
    },
    after = function()
      require("snacks").setup({
        scroll = {},
        scratch = {},
        quickfile = {},
        profiler = {},
        image = {
          force = true
        },
        explorer = {
          replace_netrw = true,
          follow_file = false
        },
        picker = {
          files = { show_hidden = true, ignored = true },
          sources = {
            explorer = {
              layout = { preview = "picker" }
            }
          },
          db = {
            sqlite3_path = nixInfo(nil, "info", "sqlite_lib")
          }
        }
      })
    end
  },
  {
    "tiny-cmdline.nvim",
    auto_enable = true,
    event = "UIEnter",
    init = function()
      vim.o.cmdheight = 0
    end,
    after = function()
      require("tiny-cmdline").setup({
        title = {
          enabled = true
        },
        position = {
          x = "50%", -- horizontal: "0%" = left, "50%" = center, "100%" = right
          y = "15%"  -- vertical:   "0%" = top,  "50%" = center, "100%" = bottom
        },
        on_reposition = require("tiny-cmdline").adapters.blink,
        native_types = {}
      })
    end
  },
  {
    "marks.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("marks").setup({
        default_mappings = true
      })
    end
  },
  {
    "todo-comments.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("todo-comments").setup()
    end
  },
  {
    "trouble.nvim",
    auto_enable = true,
    cmd = "Trouble",
    wk = {
      { "<leader>t", group = "[t]rouble" },
      { "<leader>t_", hidden = true }
    },
    keys = {
      {
        "<leader>tx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)"
      },
      {
        "<leader>tX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)"
      }
    },
    after = function()
      require("trouble").setup()
    end
  },
  {
    "volt",
    auto_enable = true,
    dep_of = { "triforce" }
  },
  {
    "triforce",
    auto_enable = true,
    dep_of = { "lualine" },
    cmd = "Triforce",
    event = "DeferredUIEnter",
    keys = {
      {
        "<leader>I",
        "<cmd>Triforce profile<cr>",
        desc = "Show Triforce Stats"
      }
    },
    after = function()
      require("triforce").setup({
        keymap = {
          -- Set to nil to disable default keymap
          show_profile = nil
        }
      })
    end
  }
}
