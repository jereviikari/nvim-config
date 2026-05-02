local keys = {}

for i = 1, 9 do
  keys[#keys + 1] = {
    "<leader>" .. i,
    function()
      require("harpoon"):list():select(i)
    end,
    desc = "which_key_ignore",
  }
end

return {
  {
    "ThePrimeagen/harpoon",
    keys = keys,
  },
}
