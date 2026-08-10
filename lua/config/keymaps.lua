-- keymaps. split out of the old opts_and_keys.lua.

vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
end, { desc = "dismiss notify popup and clear hlsearch" }
)

-- move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

-- keep cursor centered while scrolling search results
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- save everywhere
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", function()
  vim.cmd("write!")
  vim.cmd.stopinsert()
end, { desc = "Save File" }
)

-- common typos
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])
vim.cmd([[command! X x]])

-- word-wrap-aware j/k
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- clipboard (avoid clobbering the unnamed register on every delete)
vim.o.clipboard = "unnamedplus"
vim.keymap.set({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set(
  { "n", "v", "x" }, "<leader>Y", '"+yy', { noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set({ "n", "v", "x" }, "<C-a>", "gg0vG$", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set(
  "i", "<C-p>", "<C-r><C-p>+", { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)
vim.keymap.set(
  "x", "<leader>P", '"_dP',
  { noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)
