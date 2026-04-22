return {
  {
    "folke/which-key.nvim",
    opts = {
      keys = {
        scroll_down = "<Down>",
        scroll_up = "<Up>",
      },
      spec = {
        {
          mode = "n",
          { "<leader>a", group = "ai" },
          { "<leader>cg", group = "goto" },
          { "<leader>dP", group = "python debug" },
          { "<leader>r", group = "reflow" },
          { "<leader>uW", group = "indent width" },
          { "<leader>z", group = "yank/path" },
        },
      },
    },
  },
}
