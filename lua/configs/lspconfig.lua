require("nvchad.configs.lspconfig").defaults()

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom_lsp_mappings", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, {
      buffer = args.buf,
      desc = "LSP Go to implementation",
    })

    vim.keymap.set("n", "gr", vim.lsp.buf.references, {
      buffer = args.buf,
      desc = "LSP references",
    })

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
      buffer = args.buf,
      desc = "LSP rename",
    })

    vim.keymap.set("n", "K", require "configs.debug_hover", {
      buffer = args.buf,
      desc = "Debug variable or LSP hover",
    })

    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {
      buffer = args.buf,
      desc = "LSP code action",
    })
  end,
})

local servers = { "html", "cssls", "lua_ls", "gopls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
