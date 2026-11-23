local M = {}
local filetypes = { "sql", "mysql", "plsql" }

local function setup_buffer(buffer)
  vim.keymap.set({ "n", "x" }, "<leader>Br", function()
    local mode = vim.fn.mode():match "^[vV\22]" and "x" or "n"
    if vim.fn.maparg("<Plug>(DBUI_ExecuteQuery)", mode) == "" then
      vim.notify("Associate this SQL buffer with a database using <Space>Bf first", vim.log.levels.INFO)
      return ""
    end
    return "<Plug>(DBUI_ExecuteQuery)"
  end, { buffer = buffer, expr = true, remap = true, desc = "Database execute buffer/selection" })
end

function M.setup()
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 40
  vim.g.db_ui_save_location = vim.fn.stdpath "data" .. "/dadbod"
  vim.g.db_ui_execute_on_save = 0
  vim.g.db_ui_auto_execute_table_helpers = 0
  vim.fn.mkdir(vim.g.db_ui_save_location, "p", 448)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dadbod_sql_buffers", { clear = true }),
    pattern = filetypes,
    callback = function(args)
      setup_buffer(args.buf)
    end,
  })
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.tbl_contains(filetypes, vim.bo[buffer].filetype) then
      setup_buffer(buffer)
    end
  end
end

function M.completion()
  require("cmp").setup.filetype(filetypes, {
    sources = {
      { name = "vim-dadbod-completion" },
      { name = "luasnip" },
      { name = "buffer" },
    },
  })
end

return M
