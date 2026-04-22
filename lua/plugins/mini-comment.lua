local function comment_parts(ref_position)
  local ok, mini_comment = pcall(require, "mini.comment")
  if not ok then
    return nil
  end

  local config = vim.tbl_deep_extend(
    "force",
    vim.deepcopy(mini_comment.config or {}),
    vim.b.minicomment_config or {}
  )
  local options = config.options or {}
  local commentstring

  if vim.is_callable(options.custom_commentstring) then
    commentstring = options.custom_commentstring(ref_position)
  end
  commentstring = commentstring or mini_comment.get_commentstring(ref_position)

  if type(commentstring) ~= "string" or not commentstring:find("%%s") then
    vim.notify("No valid commentstring for this buffer", vim.log.levels.WARN)
    return nil
  end

  local left, right = commentstring:match("^(.-)%%s(.-)$")
  if options.pad_comment_parts ~= false then
    left = vim.trim(left)
    right = vim.trim(right)
    left = left == "" and "" or (left .. " ")
    right = right == "" and "" or (" " .. right)
  end

  return left, right
end

local function replace_keycodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function move_left(count)
  return count > 0 and string.rep("<Left>", count) or ""
end

local function start_insert_at(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col })
  vim.cmd("startinsert")
end

local function insert_comment_line(position)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^%s*") or ""
  local left, right = comment_parts({ row, col + 1 })
  if not left then
    return
  end

  local new_line = indent .. left .. right
  local insert_at = position == "above" and (row - 1) or row
  vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, { new_line })

  local new_row = position == "above" and row or (row + 1)
  start_insert_at(new_row, #indent + #left)
end

local function append_comment_keys()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local left, right = comment_parts({ row, col + 1 })
  if not left then
    return ""
  end

  local separator = line:match("%S") and " " or ""
  return replace_keycodes(
    "A" .. separator .. left .. right .. move_left(vim.fn.strchars(right))
  )
end

return {
  {
    "nvim-mini/mini.comment",
    keys = {
      {
        "gco",
        function()
          insert_comment_line("below")
        end,
        desc = "Add Comment Below",
      },
      {
        "gcO",
        function()
          insert_comment_line("above")
        end,
        desc = "Add Comment Above",
      },
      {
        "gcA",
        append_comment_keys,
        expr = true,
        desc = "Add Comment at End of Line",
      },
    },
  },
}
