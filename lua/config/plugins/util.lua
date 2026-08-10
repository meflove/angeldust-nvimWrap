return {
  {
    "tiny-inline-diagnostic",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          multiple_diag_under_cursor = true,
          show_all_diags_on_cursorline = true,
          multilines = true,
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostic
    end,
  },
  {
    "grug-far.nvim",
    auto_enable = true,
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v", "x" },
        desc = "Search and Replace",
      },
    },
    after = function()
      require("grug-far").setup({})
    end,
  },
  {
    "rooter",
    auto_enable = true,
    on_plugin = { "ctags" },
    after = function()
      require("rooter").setup({
        root_patterns = {
          "flake.nix",
          ".git/",
          ".jj/",
          ".hg/",
          "Cargo.toml",
          "go.mod",
          "package.json",
        },
      })
    end,
  },
  {
    "job",
    auto_enable = true,
    on_plugin = { "ctags" },
  },
  {
    "ctags",
    auto_enable = true,
    load = function(name)
      vim.cmd.packadd("job")
      vim.cmd.packadd("rooter")
      vim.cmd.packadd(name)
    end,
    after = function()
      require("ctags").setup()

      local function update_ctags_option()
        local project_root = vim.fn.getcwd()
        local dir = require("ctags.util").unify_path(require("ctags.config").cache_dir)
          .. require("ctags.util").path_to_fname(project_root)
        local tags = vim.tbl_filter(function(t)
          return not vim.startswith(t, require("ctags.util").unify_path(require("ctags.config").cache_dir))
        end, vim.split(vim.o.tags, ","))
        table.insert(tags, dir .. "/tags")
        vim.o.tags = table.concat(tags, ",")
      end
      require("rooter").reg_callback(update_ctags_option)
    end,
  },
  {
    "bafa",
    auto_enable = true,
    keys = {
      {
        "gb",
        function()
          require("bafa.ui").toggle()
        end,
        desc = "List open buffers",
        noremap = true,
      },
    },
    after = function()
      require("bafa").setup({
        notify = {
          provider = "vim.notify",
        },
        style = "minimal",
        ui = {
          jump_labels = {
            keys = {
              "a",
              "s",
              "d",
              "f",
              "j",
              "k",
              "l",
              ";",
              "q",
              "w",
              "e",
              "r",
              "u",
              "i",
              "o",
              "p",
              "z",
              "x",
              "c",
              "n",
              "m",
              ",",
              ".",
            },
          },
        },
        diagnostics = true,
      })
    end,
  },
  {
    "kikao",
    auto_enable = true,
    after = function()
      require("kikao").setup({
        session_file_name = nil,
        deny_on_path = {
          ".git/COMMIT_EDITMSG",
          ".git/rebase-merge/git-rebase-todo",
          "NeovimTree_",
          "fugitive://",
          "git://",
          "term://",
          "toggleterm://",
          "dap-repl://",
          "dapui://",
          "kulala://",
          "NeogitStatus",
          "health://",
        },
      })
    end,
  },
  {
    "deltaview",
    auto_enable = true,
    keys = {
      { "<leader>dm", "<cmd>DeltaMenu <CR>", mode = { "n" }, noremap = true, desc = "DeltaMenu" },
      { "<leader>dl", "<cmd>DeltaView <CR>", mode = { "n" }, noremap = true, desc = "DeltaView" },
      { "<leader>da", "<cmd>Delta <CR>", mode = { "n" }, noremap = true, desc = "Delta" },
    },
    after = function()
      require("deltaview").setup({
        fzf_picker = nil,
        keyconfig = {
          dm_toggle_keybind = "<leader>dm",
          dv_toggle_keybind = "<leader>dl",
          d_toggle_keybind = "<leader>da",
          next_hunk = "<Tab>",
          prev_hunk = "<S-Tab>",
          next_diff = "]f",
          prev_diff = "[f",
          fzf_toggle = "alt-;",
          help_legend = "d?",
        },
      })
    end,
  },
}
