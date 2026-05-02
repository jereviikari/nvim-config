return {
  {
    url = "https://codeberg.org/yaadata/codex.nvim.git",
    version = "1.0.0",
    cmd = {
      "Codex",
      "CodexFocus",
      "CodexClose",
      "CodexClearInput",
      "CodexSendSelection",
      "CodexSendFile",
      "CodexMentionFile",
      "CodexMentionDirectory",
      "CodexResume",
    },
    keys = {
      { "<leader>ao", "<cmd>Codex<cr>", desc = "Codex Toggle" },
      { "<leader>aO", "<cmd>CodexFocus<cr>", desc = "Codex Focus" },
      { "<leader>aX", "<cmd>CodexClose<cr>", desc = "Codex Close" },
      { "<leader>al", "<cmd>CodexClearInput<cr>", desc = "Codex Clear Input" },
      { "<leader>aF", "<cmd>CodexSendFile<cr>", desc = "Codex Send File" },
      { "<leader>am", "<cmd>CodexMentionFile<cr>", desc = "Codex Mention File" },
      { "<leader>aM", "<cmd>CodexMentionDirectory<cr>", desc = "Codex Mention Directory" },
      { "<leader>ar", "<cmd>CodexResume<cr>", desc = "Codex Resume" },
      { "<leader>as", "<cmd>CodexSendSelection<cr>", mode = "v", desc = "Codex Send Selection" },
    },
    opts = {},
    config = function(_, opts)
      require("codex").setup(opts)
    end,
  },
}
