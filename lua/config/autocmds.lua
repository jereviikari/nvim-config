-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function apply_custom_highlights()
  -- Ensure split separator uses a visible character.
  vim.opt.fillchars:append({ vert = "│" })

  -- Force visible color for separators.
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#FFD700", bg = "NONE", bold = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_custom_highlights,
})

apply_custom_highlights()

local function reflow_gitcommit_body()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local end_line = #lines

  for i, line in ipairs(lines) do
    if line:match("^#") then
      end_line = i - 1
      break
    end
  end

  local start_line = 3
  while start_line <= end_line and lines[start_line] == "" do
    start_line = start_line + 1
  end

  if start_line > end_line then
    vim.notify("No commit body to reflow", vim.log.levels.INFO)
    return
  end

  local view = vim.fn.winsaveview()
  vim.cmd(("silent keepjumps normal! %dGgq%dG"):format(start_line, end_line))
  vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.opt_local.wrap = false
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = false
    vim.opt_local.showbreak = ""

    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ":t")
    if filename:match("^%.tmp.*%.md$") then
      -- Codex opens prompts as temporary Markdown files; keep them quiet and ready to type.
      vim.b[event.buf].codex_prompt_markdown = true
      vim.diagnostic.enable(false, { bufnr = event.buf })

      -- Prompt text often contains literal key names like <leader>; do not auto-close them as HTML tags.
      local disable_prompt_autotag = function()
        if vim.api.nvim_buf_is_valid(event.buf) then
          pcall(require("nvim-ts-autotag.internal").detach, event.buf)
        end
      end
      vim.schedule(disable_prompt_autotag)
      vim.api.nvim_create_autocmd("InsertEnter", {
        buffer = event.buf,
        once = true,
        callback = function()
          vim.schedule(disable_prompt_autotag)
        end,
      })

      if not vim.b[event.buf].codex_prompt_started_insert then
        vim.b[event.buf].codex_prompt_started_insert = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(event.buf) and vim.api.nvim_get_current_buf() == event.buf then
            vim.cmd("startinsert")
          end
        end)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function(event)
    vim.opt_local.formatexpr = ""
    vim.keymap.set("n", "<leader>rp", function()
      if vim.api.nvim_win_get_cursor(0)[1] < 3 then
        reflow_gitcommit_body()
      else
        vim.cmd("silent keepjumps normal! gwip")
      end
    end, {
      buffer = event.buf,
      desc = "Reflow paragraph",
    })
    vim.keymap.set("n", "<leader>rP", reflow_gitcommit_body, {
      buffer = event.buf,
      desc = "Reflow commit body",
    })
    vim.keymap.set("x", "<leader>r", "gw", {
      buffer = event.buf,
      desc = "Reflow selection",
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown" },
  callback = function(event)
    vim.keymap.set("n", "<leader>rp", "gwip", {
      buffer = event.buf,
      desc = "Reflow paragraph",
    })
    vim.keymap.set("x", "<leader>r", "gw", {
      buffer = event.buf,
      desc = "Reflow selection",
    })
  end,
})

-- Apply once on startup too
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    vim.opt.fillchars:append({ vert = "│" })
--    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#FFD700", bg = "NONE", bold = true })
--  end,
--})
