local dap = require "dap"
local dapui = require "dapui"

dap.set_log_level "TRACE"

local debug_build_flags = "-ldflags=-compressdwarf=false"

vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DapCurrentMarker" })
vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DapCurrentMarker" })

vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "DapCurrentMarker",
  linehl = "DapCurrentLine",
  numhl = "DapCurrentMarker",
})

dapui.setup {
  wrap = true,
  layouts = {
    {
      elements = {
        { id = "repl", size = 1 },
      },
      size = 12,
      position = "bottom",
    },
  },
  floating = {
    max_width = 0.85,
    max_height = 0.8,
  },
  controls = { element = "repl" },
  render = { max_type_length = 0 },
}
require("configs.dap_value_colors").setup()
require("configs.dap_copy").setup()

vim.api.nvim_create_user_command("DapBreakpoints", function()
  dapui.float_element("breakpoints", { enter = true })
end, { desc = "List and enable/disable breakpoints" })

require("nvim-dap-virtual-text").setup {
  clear_on_continue = true,
  virt_text_pos = "eol",
  display_callback = function(variable)
    local value = variable.value:gsub("%s+", " ")
    if vim.fn.strchars(value) > 100 then
      value = vim.fn.strcharpart(value, 0, 100) .. "…"
    end
    return variable.name .. " = " .. value
  end,
}

-- Delve reports resumed threads in the continue response without a continued event.
dap.listeners.after.continue.go_thread_state = function(session, err, response)
  if session.config.type == "go" and not err and response and response.allThreadsContinued then
    session:event_continued { allThreadsContinued = true }
  end
end

require("dap-go").setup {
  delve = {
    path = vim.fn.exepath "dlv",
    args = {
      "--log",
      "--log-output=dap,debugger,rpc",
      "--log-dest=" .. (vim.fn.stdpath "cache") .. "/delve.log",
    },
  },
  dap_configurations = {
    {
      type = "go",
      name = "Debug current package",
      request = "launch",
      program = "${fileDirname}",
      buildFlags = debug_build_flags,
    },
    {
      type = "go",
      name = "Debug workspace",
      request = "launch",
      program = "${workspaceFolder}",
      buildFlags = debug_build_flags,
    },
  },
}

dap.configurations.go = vim.tbl_filter(function(config)
  return not vim.tbl_contains({
    "Debug",
    "Debug (Arguments)",
    "Debug (Arguments & Build Flags)",
  }, config.name)
end, dap.configurations.go)

for _, config in ipairs(dap.configurations.go) do
  config.cwd = config.cwd or "${workspaceFolder}"
  if config.buildFlags == nil or config.buildFlags == "" then
    config.buildFlags = debug_build_flags
  end
  config.stopOnEntry = false
end

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
