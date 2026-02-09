return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}

      -- Remove the big "LAZYVIM" header
      opts.dashboard.preset.header = ""

      -- Add your Projects entry (first item), avoiding duplicates
      local keys = opts.dashboard.preset.keys
      if type(keys) == "table" then
        local item = {
          icon = "󰈞 ",
          key = "p",
          desc = "Projects",
          action = ":Telescope persisted",
        }

        for _, k in ipairs(keys) do
          if k.desc == item.desc then
            return opts
          end
        end

        table.insert(keys, 1, item)
      end

      return opts
    end,
  },
}
