-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- New buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })

-- Horizontal scrolling
vim.keymap.set("n", "<C-Right>", "4zl", { silent = true })
vim.keymap.set("n", "<C-Left>", "4zh", { silent = true })

-- Resize splits with Ctrl+Alt+Arrows (works when Alt+Arrows are eaten by the terminal)
vim.keymap.set("n", "<C-M-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize - width" })
vim.keymap.set("n", "<C-M-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize + width" })
vim.keymap.set("n", "<C-M-Up>", "<cmd>resize -2<cr>", { desc = "Resize - height" })
vim.keymap.set("n", "<C-M-Down>", "<cmd>resize +2<cr>", { desc = "Resize + height" })

-- Persisted.nvim session management

---- Save current session
--vim.keymap.set("n", "<leader>zs", function()
--  require("persisted").save()
--end, { desc = "Save session" })
--
---- Load session for current working directory
--vim.keymap.set("n", "<leader>zl", function()
--  require("persisted").load()
--end, { desc = "Load session (cwd)" })
--
---- Load last session
--vim.keymap.set("n", "<leader>zL", function()
--  require("persisted").load({ last = true })
--end, { desc = "Load last session" })
--
---- List / pick sessions via Telescope
--vim.keymap.set("n", "<leader>zp", "<cmd>Telescope persisted<CR>", { desc = "Pick session" })

-- :W for :SudaWrite
vim.keymap.set("c", "W", "SudaWrite", {
  desc = "Write file with sudo",
})

-- tmux--sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "Find word (project)" })
