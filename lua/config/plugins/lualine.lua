return {
  "lualine.nvim",
  auto_enable = true,
  event = "DeferredUIEnter",
  after = function()
    -- Eviline config for lualine
    -- Author: shadmansaleh
    -- Credit: glepnir
    vim.o.showcmdloc = "statusline"

    local lualine = require("lualine")

    -- stylua: ignore
    local colors = {
      bg       = '#1E2030',
      fg       = '#cad3f5',
      yellow   = '#eed49f',
      cyan     = '#8bd5ca',
      darkblue = '#081633',
      green    = '#a6da95',
      orange   = '#f5a97f',
      violet   = '#f5bde6',
      magenta  = '#c6a0f6',
      blue     = '#8aadf4',
      red      = '#ed8796'
    }

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end
    }

    local function get_repo_name()
      local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
      if git_dir == "" then
        return ""
      end
      local git_config = git_dir .. "/config"
      if vim.fn.filereadable(git_config) == 0 then
        return ""
      end
      local config_lines = vim.fn.readfile(git_config)
      for _, line in ipairs(config_lines) do
        local url = line:match("%s+url = .+/(.+).git")
        if url then
          return url
        end
      end
      return ""
    end

    local config = {
      options = {
        component_separators = "",
        section_separators = "",
        theme = {
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } }
        }
      },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {}
      }
    }

    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left({
      function()
        return "▊"
      end,
      color = { fg = colors.magenta },
      padding = { left = 0, right = 1 }
    })

    ins_left({
      function()
        return ""
      end,
      color = function()
        local mode_color = {
          n = colors.red,
          i = colors.green,
          v = colors.blue,
          ["^V"] = colors.blue,
          V = colors.blue,
          c = colors.magenta,
          no = colors.red,
          s = colors.orange,
          S = colors.orange,
          ["^S"] = colors.orange,
          ic = colors.yellow,
          R = colors.violet,
          Rv = colors.violet,
          cv = colors.red,
          ce = colors.red,
          r = colors.cyan,
          rm = colors.cyan,
          ["r?"] = colors.cyan,
          ["!"] = colors.red,
          t = colors.red
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
      padding = { right = 1 }
    })

    ins_left({ "filesize", cond = conditions.buffer_not_empty })

    ins_left({
      function()
        local filename = vim.fn.expand("%:t")
        if filename == "" then
          return ""
        end
        local icon = ""
        if package.loaded["mini.icons"] then
          local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          local icon_data = require("mini.icons").get("filetype", ft)
          icon = icon_data .. " "
        end
        return icon .. filename
      end,
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, gui = "bold" }
    })

    ins_left({ "location" })
    ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

    ins_left({
      "diagnostics",
      sources = { "nvim_diagnostic" },
      symbols = { error = " ", warn = " ", info = " " },
      diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.cyan }
      }
    })

    ins_left({
      function()
        return "%="
      end
    })

    ins_left({
      function()
        local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
        if #buf_clients == 0 then
          return "No Active Lsp"
        end
        local lsp_names = {}
        local palette = {
          colors.cyan, colors.magenta, colors.blue, colors.green, colors.yellow, colors.orange, colors.red,
          colors.violet
        }
        local active_clients = {}
        for _, client in ipairs(buf_clients) do
          local filetypes = client.config.filetypes
          if client.name ~= "copilot" and (not filetypes or vim.fn.index(filetypes, buf_ft) ~= -1) then
            table.insert(active_clients, client)
          end
        end
        if #active_clients == 0 then
          return "No Active Lsp"
        end
        vim.api.nvim_set_hl(0, "LualineLSPSep", { fg = "#ffffff", bg = colors.bg })
        local separator = string.format("%%#%s# • %%*", "LualineLSPSep")
        for i, client in ipairs(active_clients) do
          local color = palette[(i - 1) % #palette + 1]
          local hl_group = "LualineLSP" .. i
          vim.api.nvim_set_hl(0, hl_group, { fg = color, bg = colors.bg, bold = true })
          local formatted_client = string.format("%%#%s#%s%%*", hl_group, client.name)
          table.insert(lsp_names, formatted_client)
        end
        return table.concat(lsp_names, separator)
      end,
      icon = " LSP:",
      color = { fg = "#ffffff", gui = "bold" }
    })

    ins_right({
      function()
        return "%{v:lua.require('config.util.showcmd').get()}"
      end,
      color = { fg = colors.fg }
    })

    ins_right({
      function()
        local reg = vim.fn.reg_recording()
        if reg == "" then
          return ""
        end
        return "recording @" .. reg
      end,
      color = { fg = colors.red, gui = "bold" }
    })

    ins_right({
      "o:encoding",
      fmt = string.upper,
      cond = conditions.hide_in_width,
      color = { fg = colors.green, gui = "bold" }
    })

    ins_right({
      "fileformat",
      icons_enabled = true,
      color = { fg = colors.green, gui = "bold" }
    })

    ins_right({
      function()
        return get_repo_name()
      end,
      icon = "󰊢",
      color = { fg = colors.cyan, gui = "bold" },
      cond = conditions.check_git_workspace
    })

    ins_right({ "branch", icon = "", color = { fg = colors.violet, gui = "bold" } })

    ins_right({
      "diff",
      symbols = { added = " ", modified = " ", removed = " " },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red }
      },
      cond = conditions.hide_in_width
    })

    ins_right({
      "triforce",
      level = {
        enabled = true,
        prefix = "Lv.",
        show = { level = true, bar = true, percent = false, xp = false },
        bar = { length = 6, chars = { filled = "█", empty = "░" } }
      },
      streak = { enabled = false, icon = "", show_days = true }
    })

    ins_right({
      function()
        return "▊"
      end,
      color = { fg = colors.magenta },
      padding = { left = 1 }
    })

    lualine.setup(config)
  end
}
