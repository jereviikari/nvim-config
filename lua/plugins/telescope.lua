return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "olimorris/persisted.nvim" },
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "persisted")
  end,
}
