local M = { last = "" }

function M.get()
  local cur = vim.api.nvim_eval_statusline("%S", {}).str
  if cur ~= "" then
    M.last = cur
  end
  return M.last
end

return M
