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
    after = function()
      require("ibl").setup()
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
        scroll = {
          enable = true
        },
        scratch = {
          enable = true
        },
        quickfile = {
          enable = true
        },
        -- notifier = {
        --   enabled = false,
        -- },
        explorer = {
          enable = true,
          replace_netrw = true,
          follow_file = false
        },
        indent = {
          enable = true
        },
        profiler = {},
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
    after = function()
      require("todo-comments").setup()
    end
  },
  {
    "trouble.nvim",
    auto_enable = true,
    cmd = "Trouble",
    keys = {
      {
        "<leader>txx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)"
      },
      {
        "<leader>txX",
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
