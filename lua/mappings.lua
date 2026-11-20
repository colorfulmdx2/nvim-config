require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "K", require "configs.debug_hover", { desc = "Debug variable or LSP hover" })
map("n", "<leader>rr", function()
  require("configs.script_runner").run()
end, { desc = "Run current Bash script" })

vim.api.nvim_create_user_command("RunScript", function()
  require("configs.script_runner").run()
end, { desc = "Save and run current Bash script in a bottom terminal" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
