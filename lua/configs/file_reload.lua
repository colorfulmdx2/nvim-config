local M = {}

function M.check()
  if vim.fn.getcmdtype() ~= "" then
    return
  end
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].buftype == "" and not vim.bo[buffer].modified then
      local path = vim.api.nvim_buf_get_name(buffer)
      local autoread = vim.bo[buffer].autoread
      if autoread == nil then
        autoread = vim.go.autoread
      end
      if path ~= "" and autoread and vim.fn.filereadable(path) == 1 then
        vim.cmd("silent checktime " .. buffer)
      end
    end
  end
end

function M.setup()
  local pending = false
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave", "TermClose", "CursorHold" }, {
    group = vim.api.nvim_create_augroup("reload_external_files", { clear = true }),
    callback = function()
      if pending then
        return
      end
      pending = true
      vim.schedule(function()
        pending = false
        M.check()
      end)
    end,
  })
end

return M
