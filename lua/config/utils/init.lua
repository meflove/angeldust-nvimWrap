local M = {}

local nixInfo = _G.nixInfo or function(default, ...) return default end

function M.get_nix_plugin_path(name)
  if vim.g.nix_info_plugin_name then
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  else
    return vim.api.nvim_get_runtime_file("pack/*/*/" .. name, false)[1]
  end
end

M.auto_enable_handler = {
  spec_field = "auto_enable",
  set_lazy = false,
  modify = function(plugin)
    if vim.g.nix_info_plugin_name then
      if type(plugin.auto_enable) == "table" then
        for _, name in pairs(plugin.auto_enable) do
          if not M.get_nix_plugin_path(name) then
            plugin.enabled = false
            break
          end
        end
      elseif type(plugin.auto_enable) == "string" then
        if not M.get_nix_plugin_path(plugin.auto_enable) then
          plugin.enabled = false
        end
      elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
        if not M.get_nix_plugin_path(plugin.name) then
          plugin.enabled = false
        end
      end
    end
    return plugin
  end
}

function M.lsp_ft_fallback(name)
  local nvimlspcfg = M.get_nix_plugin_path "nvim-lspconfig"
  if not nvimlspcfg then
    local matches = vim.api.nvim_get_runtime_file("pack/*/*/nvim-lspconfig", false)
    nvimlspcfg = assert(matches[1], "nvim-lspconfig not found!")
  end
  vim.api.nvim_create_user_command("LspGetFiletypesToClipboard", function(opts)
    local lspname = assert(
      opts.fargs[1] or vim.fn.getreg("+") or name, "no name to search for provided or in clipboard"
    )
    local ok, lspcfg = pcall(dofile, nvimlspcfg .. "/lsp/" .. lspname .. ".lua")
    if not ok or not lspcfg then error("failed to get config for lsp: " .. lspname) end
    vim.fn.setreg("+", "filetypes = " .. vim.inspect(lspcfg.filetypes or {}) .. ",")
  end, { nargs = '?' }
  )
  vim.schedule(function() vim.notify((name or "lsp") .. " not provided filetype", vim.log.levels.WARN) end)
  return name and dofile(nvimlspcfg .. "/lsp/" .. name .. ".lua").filetypes or {}
end

function M.try_get_mod(name, force)
  local mod = package.loaded[name]
  if not force then
    return mod
  end
  if mod == nil then
    local ok
    ok, mod = pcall(require, name)
    if not ok then
      return nil
    end
  end
  return mod
end

local loadstate = function(wk, state)
  if not wk then
    vim.schedule(function()
      vim.notify("failed to load which-key", vim.log.levels.WARN, { title = "lze wk handler" })
    end)
    return
  end
  for _, def in pairs(state.wk_deferred) do
    wk.add(def)
  end
  state.wk_deferred = {}
  state.called = false
end

local wkstate = { wk_deferred = {}, wk_spec = nil, called = false }
M.wk_handler = {
  spec_field = "wk",
  set_lazy = false,
  add = function(plugin)
    if not plugin.wk then
      return
    end
    if type(plugin.wk) == "string" then
      wkstate.wk_spec = plugin.wk
      return
    end
    local wk = M.try_get_mod "which-key"
    if wk then
      wk.add(plugin.wk)
    else
      table.insert(wkstate.wk_deferred, plugin.wk)
    end
  end,
  -- after all the specs, try again
  post_def = function()
    local wk = M.try_get_mod "which-key"
    if wk then
      loadstate(wk, wkstate)
    elseif wkstate.wk_spec then
      if not wkstate.called then
        local lze = require 'lze'
        if lze.state(wkstate.wk_spec) ~= false then
          wkstate.called = true
          lze.load {
            "WHICH_KEY_ADD_CALLS",
            on_plugin = wkstate.wk_spec,
            allow_again = true,
            lazy = true,
            load = function()
              -- load it after the after function instead of before just in case
              vim.schedule(function()
                loadstate(M.try_get_mod("which-key", true), wkstate)
              end)
            end
          }
        else
          loadstate(M.try_get_mod("which-key", true), wkstate)
        end
      end
    end
  end,
  -- if the handler is unregistered
  cleanup = function()
    wkstate.wk_deferred = {}
    wkstate.called = false
    wkstate.wk_spec = nil
  end
}

-- statusline showcmd: %S only shows a partially typed command while it is
-- being typed; keep the last one around so it stays visible afterwards.
-- Used by the lualine component (see showcmdloc = "statusline" there).
local showcmd_last = ""

function M.get_showcmd()
  local cur = vim.api.nvim_eval_statusline("%S", {}).str
  if cur ~= "" then
    showcmd_last = cur
  end
  return showcmd_last
end

return M
