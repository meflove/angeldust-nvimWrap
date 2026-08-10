local okRose, rosepine = pcall(require, "rose-pine")
if okRose then
  rosepine.setup({
    variant = "moon"
  })
end

local okCat, catppuccin = pcall(require, "catppuccin")
if okCat then
  catppuccin.setup({
    flavour = "macchiato",
    integrations = {
      gitsigns = true,
      lualine = true,
      notify = true,
      mini = true,
      noice = true,
      snacks = true,
      blink_cmp = {
        style = "bordered"
      },
      flash = true,
      indent_blankline = {
        enabled = true,
        scope_color = "mauve", -- catppuccin color (eg. `lavender`) Default: text
        colored_indent_levels = false
      },
      treesitter_context = true,
      markview = true,
      rendered_markdown = true
    }
  })
end

vim.cmd.colorscheme(nixInfo("rose-pine-moon", "settings", "colorscheme"))
