return {
  {
    "szw/vim-maximizer",
    cmd = "MaximizerToggle",
    keys = {
      { "<C-w>m", "<cmd>MaximizerToggle<cr>", desc = "Toggle Maximize Window" },
      { "<leader>wm", "<cmd>MaximizerToggle<cr>", desc = "Toggle Maximize Window" },
    },
    init = function()
      vim.g.maximizer_set_default_mapping = 0
    end,
  },
}
