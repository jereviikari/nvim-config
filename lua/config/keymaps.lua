-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- New buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })

vim.keymap.set("n", "<leader>u8", function()
  vim.wo.colorcolumn = "80"
end, { desc = "Set color column to 80" })

vim.keymap.set("n", "<leader>u0", function()
  vim.wo.colorcolumn = ""
end, { desc = "Clear color column" })

vim.keymap.set("n", "<leader>u1", function()
  vim.wo.colorcolumn = "100"
end, { desc = "Set color column to 100" })

vim.keymap.set("n", "<leader>u2", function()
  vim.wo.colorcolumn = "120"
end, { desc = "Set color column to 120" })

local function set_indent(width)
  return function()
    vim.bo.shiftwidth = width
    vim.bo.tabstop = width
    vim.bo.softtabstop = width
    vim.bo.expandtab = true
    vim.notify("Indent width set to " .. width .. " spaces")
  end
end

local function reset_indent()
  vim.cmd("setlocal shiftwidth< tabstop< softtabstop< expandtab<")

  local ok, editorconfig = pcall(require, "editorconfig")
  if ok then
    editorconfig.config(0)
  end

  vim.notify(
    ("Indent settings reset: shiftwidth=%d tabstop=%d %s"):format(
      vim.bo.shiftwidth,
      vim.bo.tabstop,
      vim.bo.expandtab and "spaces" or "tabs"
    )
  )
end

vim.keymap.set("n", "<leader>uW2", set_indent(2), { desc = "Set indent width to 2 spaces" })
vim.keymap.set("n", "<leader>uW4", set_indent(4), { desc = "Set indent width to 4 spaces" })
vim.keymap.set("n", "<leader>uWr", reset_indent, { desc = "Reset indent width to project/default" })

vim.keymap.set("n", "<leader>cP", function()
  require("config.formatters").pick()
end, { desc = "Pick Formatter" })

vim.keymap.set("n", "<leader>ad", function()
  require("config.codex").fix_diagnostics()
end, { desc = "Fix File Diagnostics with Codex" })

vim.keymap.set("n", "<leader>aD", function()
  require("config.codex").fix_workspace_diagnostics()
end, { desc = "Fix Workspace Diagnostics with Codex" })

vim.keymap.set("n", "<leader>af", function()
  require("config.codex").open_file_context()
end, { desc = "Open Codex with File Context" })

if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gz", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (Root Dir)" })
end

-- Horizontal scrolling
vim.keymap.set("n", "<M-Right>", "4zl", { silent = true })
vim.keymap.set("n", "<M-Left>", "4zh", { silent = true })
vim.keymap.set({ "n", "x" }, "<C-Right>", "w", { desc = "Next word" })
vim.keymap.set({ "n", "x" }, "<C-Left>", "b", { desc = "Previous word" })
vim.keymap.set({ "n", "x", "o" }, "<M-Up>", "{", { desc = "Previous paragraph" })
vim.keymap.set({ "n", "x", "o" }, "<M-Down>", "}", { desc = "Next paragraph" })

local function move_function(method)
  return function()
    local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
    if ok then
      pcall(move[method], "@function.outer", "textobjects")
    end
  end
end

vim.keymap.set({ "n", "x", "o" }, "<C-Up>", move_function("goto_previous_start"), { desc = "Previous function" })
vim.keymap.set({ "n", "x", "o" }, "<C-Down>", move_function("goto_next_start"), { desc = "Next function" })

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
