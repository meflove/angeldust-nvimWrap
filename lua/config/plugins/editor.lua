return {
  {
    "ts-comments.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("ts-comments").setup({})
    end
  },
  {
    "flash",
    auto_enable = true,
    event = "DeferredUIEnter",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash"
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash"
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search"
      },
      {
        "<C-x>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search"
      },
      -- Simulate nvim-treesitter incremental selection
      {
        "<c-space>",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev"
            }
          })
        end,
        desc = "Treesitter Incremental Selection"
      }
    },
    after = function()
      require("flash").setup({})
    end
  },
  {
    "which-key.nvim",
    auto_enable = true,
    wk = "which-key.nvim",
    event = "DeferredUIEnter",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)"
      }
    },
    after = function()
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader><leader>_", hidden = true }
      })
    end
  },
  {
    "hover.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    keys = {
      {
        "K",
        function()
          require("hover").open()
        end,
        desc = "Hover"
      }
    },
    after = function()
      require("hover").config({
        preview_window = true
      })
    end
  }
}
