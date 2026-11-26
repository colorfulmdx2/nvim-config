return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { branch = false },
    config = function(_, opts)
      -- Restore file windows, not terminal jobs or plugin-specific options.
      vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize", "winpos" }
      require("persistence").setup(opts)
    end,
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Session restore current directory",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load { last = true }
        end,
        desc = "Session restore last",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Session select",
      },
      {
        "<leader>qw",
        function()
          require("persistence").save()
          vim.notify "Session saved"
        end,
        desc = "Session save now",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
          vim.notify "Session will not be saved on exit"
        end,
        desc = "Session stop saving",
      },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", cmd = "DB" },
      {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "hrsh7th/nvim-cmp" },
        ft = { "sql", "mysql", "plsql" },
        config = function()
          require("configs.dadbod").completion()
        end,
      },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer", "DBUILastQueryInfo" },
    ft = { "sql", "mysql", "plsql" },
    keys = {
      { "<leader>Bu", "<cmd>DBUIToggle<CR>", desc = "Database panel" },
      { "<leader>Ba", "<cmd>DBUIAddConnection<CR>", desc = "Database add connection" },
      { "<leader>Bf", "<cmd>DBUIFindBuffer<CR>", desc = "Database associate/find SQL buffer" },
    },
    init = function()
      require("configs.dadbod").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = { width = 40 },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        path_display = { "filename_first" },
        layout_strategy = "vertical",
        layout_config = {
          width = { padding = 0 },
          height = { padding = 0 },
          vertical = {
            mirror = true,
            preview_height = 0.7,
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = require "configs.conform",
  },
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      require "configs.lint"
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-go",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Test file",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Test last",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true }
        end,
        desc = "Test output under cursor",
      },
      {
        "<leader>tp",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test output panel",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
      {
        "<leader>tq",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop test",
      },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-go" { args = { "-count=1" } },
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapBreakpoints" },
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug start/continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug step out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug breakpoint",
      },
      {
        "<leader>dl",
        "<cmd>DapBreakpoints<CR>",
        desc = "Debug breakpoint list",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "Debug conditional breakpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug REPL",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "Debug evaluate expression",
      },
      {
        "<leader>dS",
        function()
          require("dapui").float_element("stacks", { enter = true })
        end,
        desc = "Debug call stack",
      },
      {
        "<leader>dt",
        function()
          require("dap-go").debug_test()
        end,
        desc = "Debug Go test",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug UI",
      },
      {
        "<leader>dq",
        function()
          require("dap").terminate()
        end,
        desc = "Debug terminate",
      },
    },
    config = function()
      require "configs.dap"
    end,
  },
  {
    "leap.nvim",
    url = "https://codeberg.org/andyg/leap.nvim",
    lazy = false,
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
      vim.keymap.set({ "x", "o" }, "x", "<Plug>(leap-forward-till)", { desc = "Leap forward till" })
      vim.keymap.set({ "x", "o" }, "X", "<Plug>(leap-backward-till)", { desc = "Leap backward till" })
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { desc = "Leap from window" })
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    opts = function()
      local opts = require "nvchad.configs.treesitter"
      local parser_install_dir = vim.fn.stdpath "data" .. "/treesitter"

      vim.opt.runtimepath:prepend(parser_install_dir)

      opts.ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "sql",
        "go",
        "gomod",
        "gosum",
        "gowork",
      }

      opts.parser_install_dir = parser_install_dir
      opts.sync_install = false
      opts.auto_install = true

      opts.highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      }

      return opts
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },
    },
  },
}
