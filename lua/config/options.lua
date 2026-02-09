-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Make Telescope the default picker
vim.g.lazyvim_picker = "telescope"

-- Allow left/right arrow keys to wrap across line boundaries
vim.opt.whichwrap:append("<,>,[,]")

-- Use absolute line numbers (disable relative numbering)
vim.opt.relativenumber = false

vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

--vim.opt.fillchars:append({ vert = "┃" })

-- Show visible split borders
--vim.opt.fillchars = {
--  vert = "│",
--  horiz = "─",
--  horizup = "┴",
--  horizdown = "┬",
--  vertleft = "┤",
--  vertright = "├",
--  verthoriz = "┼",
--}

--vim.cmd([[ hi WinSeparator guifg=#FFD700 guibg=NONE ]])
