return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    require("telescope").load_extension("persisted")
    return opts
  end,
}
