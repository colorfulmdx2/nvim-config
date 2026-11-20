local M = {}
local namespace = vim.api.nvim_create_namespace "dap_value_colors"
local attached = {}

-- Byte offsets match Neovim's highlight columns, including Cyrillic strings.
function M.tokens(value)
  local tokens = {}
  local i = 1
  while i <= #value do
    local char = value:sub(i, i)
    local finish, group
    if char == '"' or char == "`" then
      finish = i + 1
      while finish <= #value do
        local current = value:sub(finish, finish)
        if current == "\\" and char == '"' then
          finish = finish + 2
        elseif current == char then
          finish = finish + 1
          break
        else
          finish = finish + 1
        end
      end
      finish = math.min(finish, #value + 1)
      group = "DapValueString"
    elseif i == 1 or not value:sub(i - 1, i - 1):match "[%w_]" then
      local tail = value:sub(i)
      local word = tail:match "^[%a_][%w_]*"
      if word == "true" or word == "false" then
        finish, group = i + #word, "DapValueBoolean"
      elseif word == "nil" then
        finish, group = i + #word, "DapValueNil"
      else
        local number = tail:match "^[-+]?0[xX]%x+"
          or tail:match "^[-+]?%d*%.?%d+[eE][-+]?%d+"
          or tail:match "^[-+]?%d+%.?%d*"
          or tail:match "^[-+]?%.%d+"
        if number and not tail:sub(#number + 1, #number + 1):match "[%w_]" then
          finish, group = i + #number, "DapValueNumber"
        elseif word then
          i = i + #word - 1
        end
      end
    end
    if group then
      tokens[#tokens + 1] = { start_col = i - 1, end_col = finish - 1, group = group }
      i = finish
    else
      i = i + 1
    end
  end
  return tokens
end

function M.refresh(buffer)
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
  local canvas_namespace = vim.api.nvim_create_namespace "dapui"
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buffer, canvas_namespace, 0, -1, { details = true })) do
    local row, column, details = mark[2], mark[3], mark[4]
    -- Keep changed values yellow; only color value spans, never names or types.
    if details.hl_group == "DapUIValue" and details.end_row == row then
      local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1] or ""
      local value = line:sub(column + 1, details.end_col)
      for _, token in ipairs(M.tokens(value)) do
        vim.api.nvim_buf_set_extmark(buffer, namespace, row, column + token.start_col, {
          end_col = column + token.end_col,
          hl_group = token.group,
          priority = 10000,
        })
      end
    end
  end
end

local function attach(buffer)
  if attached[buffer] then
    return
  end
  attached[buffer] = true
  local pending = false
  local function refresh()
    if pending then
      return
    end
    pending = true
    vim.schedule(function()
      pending = false
      M.refresh(buffer)
    end)
  end
  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = refresh,
    on_detach = function()
      attached[buffer] = nil
    end,
  })
  refresh()
end

function M.setup()
  local filetypes = { "dapui_hover", "dapui_scopes", "dapui_watches" }
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dap_value_colors", { clear = true }),
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
