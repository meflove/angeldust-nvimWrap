vim.opt.winborder = "rounded"
vim.opt.completeopt:append("popup")
vim.o.cmdheight = 0

local msgs = require("vim._core.ui2.messages")
local ui2 = require("vim._core.ui2")
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
  orig_set_pos(tgt)
  if (tgt == "msg" or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
    pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
      relative = "editor",
      anchor = "NE",
      row = 1,
      col = vim.o.columns - 1,
      border = "rounded"
    })
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "msg",
  callback = function()
    local win = ui2.wins and ui2.wins.msg
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_option_value(
        "winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder", { scope = "local", win = win }
      )
    end
  end
})

-- LSP progress notifications live in lua/config/lsp/init.lua (adapted to ui2 there).

ui2.enable({
  enable = true, -- Whether to enable or disable the UI.
  msg = { -- Options related to the message module.
    ---@type string | table<string, 'cmd' | 'msg' | 'pager'> Default message target
    --- or table mapping |ui-messages| kinds and triggers to a target.
    targets = {
      [""] = "msg",
      empty = "cmd",
      bufwrite = "msg",
      confirm = "cmd",
      emsg = "pager",
      echo = "msg",
      echomsg = "msg",
      echoerr = "pager",
      completion = "cmd",
      list_cmd = "pager",
      lua_error = "pager",
      lua_print = "msg",
      -- "pager" windows render at the bottom of the screen (relative to
      -- 'laststatus', i.e. in the cmdline area); only the "msg" window is
      -- repositioned to the top-right by the set_pos override above, so LSP
      -- progress must go there too.
      progress = "msg",
      rpc_error = "pager",
      quickfix = "msg",
      search_cmd = "cmd",
      search_count = "cmd",
      shell_cmd = "pager",
      shell_err = "pager",
      shell_out = "pager",
      shell_ret = "msg",
      undo = "msg",
      verbose = "pager",
      wildlist = "cmd",
      wmsg = "msg",
      typed_cmd = "cmd"
    },
    cmd = { -- Options related to messages in the cmdline window.
      height = 0.5 -- Maximum height while expanded for messages beyond 'cmdheight'.
    },
    dialog = { -- Options related to dialog window.
      height = 0.5 -- Maximum height.
    },
    msg = { -- Options related to msg window.
      height = 0.3,  -- Maximum height.
      timeout = 4000 -- Time a message is visible in the message window.
    },
    pager = { -- Options related to message window.
      height = 1 -- Maximum height.
    }
  }
})
