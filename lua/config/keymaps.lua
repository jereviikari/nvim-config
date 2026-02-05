-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Persisted.nvim session management

-- Save current session
vim.keymap.set("n", "<leader>zs", function()
  require("persisted").save()
end, { desc = "Save session" })

-- Load session for current working directory
vim.keymap.set("n", "<leader>zl", function()
  require("persisted").load()
end, { desc = "Load session (cwd)" })

-- Load last session
vim.keymap.set("n", "<leader>zL", function()
  require("persisted").load({ last = true })
end, { desc = "Load last session" })

-- List / pick sessions via Telescope
vim.keymap.set("n", "<leader>zp", "<cmd>Telescope persisted<CR>", { desc = "Pick session" })

-- :W for :SudaWrite
vim.keymap.set("c", "W", "SudaWrite", {
  desc = "Write file with sudo",
})
