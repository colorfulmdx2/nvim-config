local M = {}

function M.value_at(buffer, row)
  local spans = {}
  local namespace = vim.api.nvim_create_namespace "dapui"
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buffer, namespace, 0, -1, { details = true })) do
    local details = mark[4]
    if
      (details.hl_group == "DapUIValue" or details.hl_group == "DapUIModifiedValue") and details.end_row == mark[2]
    then
      local line = vim.api.nvim_buf_get_lines(buffer, mark[2], mark[2] + 1, false)[1] or ""
      spans[mark[2]] = {
        value = line:sub(mark[3] + 1, details.end_col),
        continuation = line:sub(1, mark[3]):match "^%s*$" ~= nil,
      }
    end
  end
  if not spans[row] then
    return nil
  end
  while spans[row].continuation and spans[row - 1] do
    row = row - 1
  end
  local values = { spans[row].value }
  while spans[row + 1] and spans[row + 1].continuation do
    row = row + 1
    values[#values + 1] = spans[row].value:gsub("^%s+", "")
  end
  local value = table.concat(values, "\n")
  if value:sub(1, 1) == '"' and value:sub(-1) == '"' then
    local ok, decoded = pcall(vim.json.decode, value)
    if ok and type(decoded) == "string" then
      value = decoded
    end
  elseif value:sub(1, 1) == "`" and value:sub(-1) == "`" then
    value = value:sub(2, -2)
  end
  return value
end

function M.copy(whole_line)
  local buffer = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local value = whole_line and vim.api.nvim_get_current_line() or M.value_at(buffer, row)
  if value == nil then
    vim.notify("Place the cursor on a variable value", vim.log.levels.INFO)
    return
  end
  vim.fn.setreg('"', value, "v")
  local ok = pcall(vim.fn.setreg, "+", value, "v")
  vim.notify(ok and "Copied to clipboard" or "Copied to unnamed register; system clipboard unavailable")
end

local function attach(buffer)
  vim.keymap.set("n", "y", function()
    M.copy(false)
  end, { buffer = buffer, desc = "Copy variable value" })
  vim.keymap.set("n", "Y", function()
    M.copy(true)
  end, { buffer = buffer, desc = "Copy variable row" })
end

function M.setup()
  local filetypes = { "dapui_hover", "dapui_scopes", "dapui_watches" }
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dap_copy", { clear = true }),
    pattern = filetypes,
    callback = function(args)
      attach(args.buf)
    end,
  })
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.tbl_contains(filetypes, vim.bo[buffer].filetype) then
      attach(buffer)
    end
  end
end

return M
