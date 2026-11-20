return function()
  local dap = package.loaded["dap"]
  local session = dap and dap.session()
  if session and session.stopped_thread_id then
    require("dapui").eval()
  else
    vim.lsp.buf.hover()
  end
end
