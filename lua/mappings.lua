require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "K", require "configs.debug_hover", { desc = "Debug variable or LSP hover" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
