-- neovim options (vim.o / vim.opt / vim.g).
-- split out of the old opts_and_keys.lua. leaders live in init.lua.

-- how neovim displays whitespace
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- search
vim.opt.hlsearch = true
vim.opt.cursorline = true
vim.opt.showmatch = true

-- preview substitutions live, as you type
vim.opt.inccommand = "split"

-- keep some context around the cursor
vim.opt.scrolloff = 10

-- line numbers
vim.wo.number = true
vim.wo.signcolumn = "yes"
vim.wo.relativenumber = true

-- mouse
vim.o.mouse = "a"

-- indent
vim.opt.cpoptions:append("I")
vim.o.expandtab = true

-- stops line wrapping from being confusing
vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- responsiveness
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- completion
vim.o.completeopt = "menu,preview,noselect"

-- NOTE: make sure your terminal supports this
vim.o.termguicolors = true
