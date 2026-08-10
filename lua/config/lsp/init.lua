-- LSP core (nvim-lspconfig) + per-language specs loaded via the lzextras lsp handler.
-- lspDebugMode is a setting in module.nix (read via nixInfo).
if nixInfo(false, "settings", "lspDebugMode") then
  vim.lsp.log.set_level("debug")
end

vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())

-- LSP progress, adapted from the old snacks.notifier version to the native ui2
-- message system (ui2 is enabled in lua/config/ui2.lua before this file loads):
-- nvim_echo() with a stable `id` updates the message in place instead of
-- stacking new ones, and kind/status/percent/title map to the
-- |progress-message| fields ui2 understands.
--
-- A repeating timer re-renders the message while a task is running, so the
-- spinner keeps animating even between LspProgress events (LSPs often go
-- silent for seconds at, say, 47%). Each tick just re-echoes the same id.
--
-- progress[client_id] = {
--   entries = { {token, title, message, done}, ... },  -- one per progress token
--   last = { title, percent },                          -- header fields of the newest event
-- }
local progress = vim.defaulttable()
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local SPINNER_INTERVAL_MS = 80
local spinner_timer ---@type uv.uv_timer_t?

--- Redraw the progress message for one client. Returns true while it still
--- has unfinished tokens.
local function render_progress(client)
  local state = progress[client.id]
  if not state or not state.entries or #state.entries == 0 then
    return false
  end

  local has_active = false
  -- nvim renders a header line "title: NN% source" by itself from the
  -- structured opts below, so the content only carries what the header
  -- lacks: per-token status (spinner / ✓) and the detail message. Chunks
  -- carry real highlight groups — ui2 does not parse markdown.
  local chunks = {}
  for _, v in ipairs(state.entries) do
    local done_hl = v.done and "MoreMsg" or nil
    chunks[#chunks + 1] = {
      (v.done and "✓ " or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1] .. " "),
      done_hl or "Special"
    }
    chunks[#chunks + 1] = { (v.message or v.title or "") .. "\n", done_hl or "Normal" }
    has_active = has_active or not v.done
  end
  -- drop the trailing newline of the last line
  chunks[#chunks][1] = chunks[#chunks][1]:sub(1, -2)

  -- While the cmdline is open, ui2 routes every new message to the pager
  -- window at the bottom of the screen (ui.cmd.expand in vim._core.ui2), so
  -- re-echoing here would haul the progress message down into the cmdline
  -- area on every spinner tick. Freeze the message instead: skip the echo
  -- while typing, the next tick after the cmdline closes refreshes it.
  if vim.fn.getcmdtype() ~= "" or vim.fn.getcmdwintype() ~= "" then
    return has_active
  end

  vim.api.nvim_echo(chunks, false, {
    id = "lsp.progress." .. client.name,
    kind = "progress",
    source = client.name,
    title = state.last.title,
    status = has_active and "running" or "success",
    percent = has_active and state.last.percent or 100
  })
  return has_active
end

--- One global timer tick: re-render every client that still has state and
--- stop the timer once nothing is running (it is restarted on demand — uv
--- timers cannot be revived with :start() only once, so always re-check).
local redraw ---@param client vim.lsp.Client

local function spinner_tick()
  local any_active = false
  for client_id in pairs(progress) do
    local c = vim.lsp.get_client_by_id(client_id)
    if c and redraw(c) then
      any_active = true
    else
      progress[client_id] = nil
    end
  end
  if not any_active then
    spinner_timer:stop()
  end
end

local function start_spinner_timer()
  if not spinner_timer then
    spinner_timer = vim.uv.new_timer()
  end
  -- a stopped uv timer stays allocated; :is_active() guards a re-:start()
  if not spinner_timer:is_active() then
    spinner_timer:start(SPINNER_INTERVAL_MS, SPINNER_INTERVAL_MS, vim.schedule_wrap(spinner_tick))
  end
end

--- Render a client and drop its state once every token has finished (the
--- final "✓" rendering stays on screen until the msg-window timeout).
--- Returns true while the client still has unfinished tokens — spinner_tick
--- relies on this to know whether to keep the timer running.
redraw = function(client)
  if render_progress(client) then
    start_spinner_timer()
    return true
  end
  progress[client.id] = nil
  return false
end

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("lsp_progress_ui2", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= "table" then
      return
    end
    local state = progress[client.id]
    state.entries = state.entries or {}

    -- one entry per progress token (a client may run several at once);
    -- an "end" event marks its entry done instead of dropping it, so the
    -- finished line with "✓" keeps animating alongside the running ones.
    for i = 1, #state.entries + 1 do
      if i == #state.entries + 1 or state.entries[i].token == ev.data.params.token then
        state.entries[i] = {
          token = ev.data.params.token,
          title = value.title or "",
          message = value.message,
          done = value.kind == "end"
        }
        break
      end
    end
    state.last = { title = value.title, percent = value.kind == "end" and 100 or value.percentage }

    redraw(client)
  end
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("lsp_progress_cleanup", { clear = true }),
  callback = function()
    if spinner_timer then
      spinner_timer:close()
      spinner_timer = nil
    end
  end
})

nixInfo.lze.load({
  {
    "nvim-lspconfig",
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function()
      vim.lsp.config("*", {
        on_attach = require("config.lsp.on_attach")
      })
    end
  },
  { import = "config.lsp.languages.lua" },
  { import = "config.lsp.languages.nix" },
  { import = "config.lsp.languages.python" },
  { import = "config.lsp.languages.bash" },
  { import = "config.lsp.languages.md" },
  { import = "config.lsp.languages.rust" },
  { import = "config.lsp.languages.yaml" },
  { import = "config.lsp.languages.json" },
  { import = "config.lsp.languages.typescript" },
  { import = "config.lsp.languages.nulang" },
  { import = "config.lsp.languages.cpp" }
})
