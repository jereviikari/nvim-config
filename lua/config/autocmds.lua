-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Ensure split separator uses a visible character
    vim.opt.fillchars:append({ vert = "│" })

    -- Force visible color for separators
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#FFD700", bg = "NONE", bold = true })
  end,
})

-- Apply once on startup too
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    vim.opt.fillchars:append({ vert = "│" })
--    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#FFD700", bg = "NONE", bold = true })
--  end,
--})
