return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      local old_on_highlights = opts.on_highlights

      opts.on_highlights = function(highlights, colors)
        if old_on_highlights then
          old_on_highlights(highlights, colors)
        end

        -- Make vim-illuminate matches easier to notice than the default gutter-colored background.
        local illuminate = { bg = "#5c4f2f" }
        highlights.IlluminatedWordText = illuminate
        highlights.IlluminatedWordRead = illuminate
        highlights.IlluminatedWordWrite = illuminate
        highlights.illuminatedCurWord = illuminate
        highlights.illuminatedWord = illuminate
      end
    end,
  },
}
