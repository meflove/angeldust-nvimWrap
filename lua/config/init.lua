-- Entry point for the neovim config.
-- Sets up the `nixInfo` bridge (values handed over from nix via nix/*.nix),
-- registers the lze handlers, then loads the modular config under lua/config/.
--
-- Migrated from nixCats: the nixCats global, the non-nix fallback, and the
-- for_cat handler were all removed (pure-nix, single build). Only `auto_enable`
-- remains — it disables an lze spec whose plugin wasn't installed by nix, which
-- is exactly what lets `config.specs.<lang>.enable = false` work cleanly.

-- the info plugin name is set by the wrapper (vim.g.nix_info_plugin_name).
-- pure-nix => it is always set, so no fallback is needed.
_G.nixInfo = require(vim.g.nix_info_plugin_name)
nixInfo.isNix = true
nixInfo.utils = require("config.utils")

-- lze is the lazy loader; lzextras adds the lsp handler + helpers.
-- merge lzextras' metatable onto lze so `nixInfo.lze` has both.
nixInfo.lze = setmetatable(require("lze"), getmetatable(require("lzextras")))

-- Register handlers. Order matters: auto_enable before lsp, because the lsp
-- handler also reads `enabled` (set by auto_enable) during its modify hook.
nixInfo.lze.register_handlers({
  nixInfo.utils.auto_enable_handler,
  nixInfo.utils.wk_handler,
  -- lzextras lsp handler: set up lsps from the `lsp = { ... }` spec field,
  -- triggered only on the relevant filetypes.
  nixInfo.lze.lsp
})

-- Performance: when an lsp spec omits filetypes, derive them from lspconfig
-- without loading the whole lspconfig plugin at startup.
-- nixInfo.lze.h.lsp.set_ft_fallback(function(name)
--   local lspcfg = nixInfo.get_nix_plugin_path("nvim-lspconfig")
--   if lspcfg then
--     local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
--     return (ok and cfg or {}).filetypes or {}
--   end
--   return (vim.lsp.config[name] or {}).filetypes or {}
-- end)
nixInfo.lze.h.lsp.set_ft_fallback(nixInfo.utils.lsp_ft_fallback)

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.colorscheme")
require("config.ui2")

-- lsp configs (nvim-lspconfig + per-language specs)
require("config.lsp")

nixInfo.lze.load({
  -- lint / format
  { import = "config.nvim-lint" },
  { import = "config.format" },
  --plugins
  { import = "config.plugins.ui" },
  { import = "config.plugins.editor" },
  { import = "config.plugins.git" },
  { import = "config.plugins.util" },
  { import = "config.plugins.treesitter" },
  { import = "config.plugins.completion" },
  { import = "config.plugins.lualine" }
})
