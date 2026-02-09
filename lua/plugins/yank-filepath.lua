return {
  {
    -- No dependency, just a place to run init early
    "folke/which-key.nvim",
    optional = true,
    init = function()
      vim.keymap.set("n", "<leader>zf", function()
        vim.fn.setreg("+", vim.fn.expand("%"))
      end, { desc = "Yank relative file path" })

      vim.keymap.set("n", "<leader>zF", function()
        vim.fn.setreg("+", vim.fn.expand("%:p"))
      end, { desc = "Yank absolute file path" })
    end,
  },
}
