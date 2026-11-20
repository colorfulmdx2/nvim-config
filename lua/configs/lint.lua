local lint = require "lint"

lint.linters_by_ft = {
  go = { "golangcilint" },
}

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("lint", { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})
