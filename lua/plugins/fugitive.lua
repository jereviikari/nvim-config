return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gclog",
      "Gdiffsplit",
      "Gedit",
      "Ggrep",
      "Gread",
      "Gsplit",
      "Gtabedit",
      "Gvdiffsplit",
      "Gvsplit",
      "Gwrite",
    },
    keys = {
      { "<leader>gF", "<cmd>Git<cr>", desc = "Fugitive" },
    },
  },
}
