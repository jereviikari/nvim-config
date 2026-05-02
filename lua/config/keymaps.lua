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

-- Toggle only Neovim diagnostics for the current buffer; this hides linter output without stopping LSP clients.
local function toggle_buffer_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local enable = not vim.diagnostic.is_enabled({ bufnr = bufnr })

  vim.diagnostic.enable(enable, { bufnr = bufnr })
  if not enable then
    vim.diagnostic.reset(nil, bufnr)
  end

  if enable then
    pcall(function()
      require("lint").try_lint()
    end)
  end

  vim.notify("Diagnostics " .. (enable and "enabled" or "disabled"))
end

vim.api.nvim_create_user_command("ToggleDiagnostics", toggle_buffer_diagnostics, {
  desc = "Toggle diagnostics for current buffer",
  force = true,
})

vim.keymap.set({ "n", "x", "i" }, "<A-d>", toggle_buffer_diagnostics, { desc = "Toggle Diagnostics" })
vim.keymap.set({ "n", "x" }, "<leader>ud", toggle_buffer_diagnostics, { desc = "Toggle Diagnostics" })

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

-- Editor-style selection with Shift+Arrow; Ctrl+Shift+Left/Right selects by word.
-- These are explicit because terminal Neovim does not treat Shift+Arrow as selection by default.
local select_motions = {
  ["<S-Left>"] = "<Left>",
  ["<S-Right>"] = "<Right>",
  ["<S-Up>"] = "<Up>",
  ["<S-Down>"] = "<Down>",
}

for key, motion in pairs(select_motions) do
  vim.keymap.set("n", key, "v" .. motion, { desc = "Start selection" })
  vim.keymap.set("x", key, motion, { desc = "Extend selection" })
  vim.keymap.set("i", key, "<C-\\><C-n>v" .. motion, { desc = "Start selection" })
end

vim.keymap.set({ "n", "x" }, "<C-Right>", "w", { desc = "Next word" })
vim.keymap.set({ "n", "x" }, "<C-Left>", "b", { desc = "Previous word" })
vim.keymap.set("i", "<C-Right>", "<C-o>w", { desc = "Next word" })
vim.keymap.set("i", "<C-Left>", "<C-o>b", { desc = "Previous word" })
vim.keymap.set("n", "<C-S-Right>", "vw", { desc = "Select next word" })
vim.keymap.set("n", "<C-S-Left>", "vb", { desc = "Select previous word" })
vim.keymap.set("x", "<C-S-Right>", "w", { desc = "Select next word" })
vim.keymap.set("x", "<C-S-Left>", "b", { desc = "Select previous word" })
vim.keymap.set("i", "<C-S-Right>", "<C-\\><C-n>vw", { desc = "Select next word" })
vim.keymap.set("i", "<C-S-Left>", "<C-\\><C-n>vb", { desc = "Select previous word" })
vim.keymap.set({ "n", "x", "o" }, "<M-Up>", "{", { desc = "Previous paragraph" })
vim.keymap.set({ "n", "x", "o" }, "<M-Down>", "}", { desc = "Next paragraph" })

--vim.keymap.set("n", "<leader>ap", "v{", { desc = "Select previous paragraph" })
--vim.keymap.set("n", "<leader>an", "v}", { desc = "Select next paragraph" })
--
--vim.keymap.set("x", "<leader>ap", "{", { desc = "Extend selection previous paragraph" })
--vim.keymap.set("x", "<leader>an", "}", { desc = "Extend selection next paragraph" })
--
--vim.keymap.set("i", "<leader>ap", "<C-\\><C-n>v{", { desc = "Select previous paragraph" })
--vim.keymap.set("i", "<leader>an", "<C-\\><C-n>v}", { desc = "Select next paragraph" })


--vim.keymap.set("n", "<C-S-k>", "v{")
--vim.keymap.set("n", "<C-S-j>", "v}")
--
--vim.keymap.set("x", "<C-S-k>", "{")
--vim.keymap.set("x", "<C-S-j>", "}")


--vim.keymap.set("n", "gz", "v{", { desc = "Select previous paragraph" })
--vim.keymap.set("n", "gZ", "v}", { desc = "Select next paragraph" })
--
--vim.keymap.set("x", "gz", "{", { desc = "Extend selection previous paragraph" })
--vim.keymap.set("x", "gZ", "}", { desc = "Extend selection next paragraph" })

--vim.keymap.set("n", "g{", "v{", { desc = "Select previous paragraph" })
--vim.keymap.set("n", "g}", "v}", { desc = "Select next paragraph" })
--vim.keymap.set("x", "g{", "{", { desc = "Extend selection up paragraph" })
--vim.keymap.set("x", "g}", "}", { desc = "Extend selection down paragraph" })


--vim.keymap.set("n", "<M-S-Up>", "v{", { desc = "Select previous paragraph" })
--vim.keymap.set("n", "<M-S-Down>", "v}", { desc = "Select next paragraph" })
--
--vim.keymap.set("x", "<M-S-Up>", "{", { desc = "Extend selection up paragraph" })
--vim.keymap.set("x", "<M-S-Down>", "}", { desc = "Extend selection down paragraph" })
--
--vim.keymap.set("i", "<M-S-Up>", "<C-\\><C-n>v{", { desc = "Select previous paragraph" })
--vim.keymap.set("i", "<M-S-Down>", "<C-\\><C-n>v}", { desc = "Select next paragraph" })

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
