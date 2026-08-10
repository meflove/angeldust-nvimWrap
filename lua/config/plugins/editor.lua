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
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]iff" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]rouble" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true }
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
