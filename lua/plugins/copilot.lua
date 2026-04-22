local function copilot_enabled()
  local ok, client = pcall(require, "copilot.client")
  return ok and not client.is_disabled()
end

local function set_copilot_enabled(enabled)
  local command = require("copilot.command")
  if enabled then
    command.enable()
  else
    command.disable()
  end
end

return {
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      opts.suggestion = vim.tbl_deep_extend("force", opts.suggestion or {}, {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          next = "<M-n>",
          prev = "<M-p>",
        },
      })
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
      set_copilot_enabled(false)
    end,
    keys = {
      {
        "<leader>ac",
        function()
          set_copilot_enabled(not copilot_enabled())
          vim.notify("Copilot " .. (copilot_enabled() and "enabled" or "disabled"))
        end,
        desc = "Toggle Copilot Suggestions",
      },
    },
  },
}
