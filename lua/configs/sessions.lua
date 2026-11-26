local M = {}

function M.setup(opts)
  vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize", "winpos" }
  local argv = vim.fn.argv()
  local directory = #argv == 1 and vim.fn.isdirectory(argv[1]) == 1 and vim.fn.fnamemodify(argv[1], ":p") or nil
  opts.git_use_branch_name = function(path)
    local result = vim
      .system({ "git", "-C", path or vim.fn.getcwd(), "rev-parse", "--abbrev-ref", "HEAD" }, { text = true })
      :wait()
    return result.code == 0 and vim.trim(result.stdout) or nil
  end
  if #argv > 0 and not directory then
    opts.git_auto_restore_on_branch_change = false
  end
  opts.no_restore_cmds = {
    function(startup)
      -- On a first directory launch there is no session yet. The upstream
      -- branch suffix makes its directory comparison fail; keep saving enabled.
      if startup and directory then
        vim.fn.chdir(directory)
        require("auto-session.config").auto_save = true
      end
      -- Also observe branch changes before the first session has been created.
      local cwd = vim.fn.getcwd()
      if
        opts.git_auto_restore_on_branch_change
        and opts.git_use_branch_name(cwd)
        and not vim.tbl_contains(opts.suppressed_dirs, cwd)
      then
        require("auto-session.git").start_watcher(vim.fn.getcwd(), ".git/HEAD")
      end
    end,
  }
  require("auto-session").setup(opts)
end

function M.restore(last)
  if require("auto-session.lib").has_modified_buffers() then
    vim.notify("Save your changes before restoring a session (:wa)", vim.log.levels.WARN)
    return
  end
  if last == "select" then
    require("auto-session").search()
  elseif last then
    local session = require("auto-session.lib").get_latest_session(require("auto-session").get_root_dir())
    if session then
      require("auto-session").restore_session(session)
    end
  else
    require("auto-session").restore_session()
  end
end

return M
