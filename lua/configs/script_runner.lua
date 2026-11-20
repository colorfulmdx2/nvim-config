local M = {}
local terminal

function M.root(path)
  return vim.fs.root(path, ".git") or vim.fs.root(path, { "go.work", "go.mod" }) or vim.fs.dirname(path)
end

local function show(buffer)
  local window = vim.fn.bufwinid(buffer)
  if window == -1 then
    vim.cmd "botright 4split"
    vim.api.nvim_win_set_buf(0, buffer)
  else
    vim.api.nvim_set_current_win(window)
  end
  vim.cmd "startinsert"
end

function M.run()
  local source = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(source)
  local filetype = vim.bo[source].filetype
  if vim.bo[source].buftype ~= "" or path == "" then
    vim.notify("Open a saved Bash script first", vim.log.levels.WARN)
    return
  end
  if filetype ~= "sh" and filetype ~= "bash" and not path:match "%.sh$" and not path:match "%.bash$" then
    vim.notify("RunScript supports Bash scripts (.sh/.bash or filetype sh)", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable "bash" ~= 1 then
    vim.notify("bash is not available in PATH", vim.log.levels.ERROR)
    return
  end
  if terminal and vim.api.nvim_buf_is_valid(terminal.buffer) and vim.fn.jobwait({ terminal.job }, 0)[1] == -1 then
    show(terminal.buffer)
    vim.notify("A script is still running; Ctrl+C interrupts it before another run", vim.log.levels.INFO)
    return
  end

  local saved, save_error = pcall(vim.api.nvim_buf_call, source, function()
    vim.cmd "update"
  end)
  if not saved then
    vim.notify("Could not save script: " .. tostring(save_error), vim.log.levels.ERROR)
    return
  end
  -- Saving can format or rename a buffer; use its current absolute path.
  path = vim.api.nvim_buf_get_name(source)
  local buffer = vim.api.nvim_create_buf(false, true)
  show(buffer)
  local job = vim.fn.jobstart({ "bash", path }, {
    term = true,
    cwd = M.root(path),
    on_exit = function(_, code)
      vim.schedule(function()
        vim.notify(vim.fs.basename(path) .. ": exit " .. code, code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
      end)
    end,
  })
  if job <= 0 then
    vim.notify("Could not start bash", vim.log.levels.ERROR)
    return
  end
  local previous = terminal
  terminal = { buffer = buffer, job = job }
  vim.bo[buffer].bufhidden = "hide"
  vim.bo[buffer].swapfile = false
  if previous and vim.api.nvim_buf_is_valid(previous.buffer) then
    vim.api.nvim_buf_delete(previous.buffer, { force = true })
  end
end

return M
