local M = {}

local function format_entry(entry)
  return entry.display
end

local function run_formatter(conform, bufnr, entry)
  if entry.kind == "default" then
    conform.format({ bufnr = bufnr })
    return
  end

  conform.format({
    bufnr = bufnr,
    formatters = entry.name and { entry.name } or nil,
    lsp_format = entry.name and "never" or "prefer",
  })
end

local function formatter_entries(formatters, lsp)
  local entries = {}
  local names = vim.tbl_map(function(formatter)
    return formatter.name
  end, formatters)

  if lsp then
    table.insert(names, "LSP")
  end

  table.insert(entries, {
    kind = "default",
    display = "default: " .. table.concat(names, " -> "),
  })

  for index, formatter in ipairs(formatters) do
    local suffix = #formatters == 1 and not lsp and " (current default)" or (" (default #" .. index .. ")")
    table.insert(entries, {
      kind = "formatter",
      name = formatter.name,
      display = formatter.name .. suffix,
    })
  end

  if lsp then
    table.insert(entries, {
      kind = "lsp",
      display = #formatters == 0 and "LSP (current default)" or "LSP (default fallback)",
    })
  end

  return entries
end

function M.pick()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim is not available", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local formatters, lsp = conform.list_formatters_to_run(bufnr)
  if vim.tbl_isempty(formatters) and not lsp then
    vim.notify("No available formatters for this buffer", vim.log.levels.WARN)
    return
  end

  local entries = formatter_entries(formatters, lsp)
  local telescope_ok, pickers = pcall(require, "telescope.pickers")
  if not telescope_ok then
    vim.ui.select(entries, {
      prompt = "Formatter",
      format_item = format_entry,
    }, function(entry)
      if entry then
        run_formatter(conform, bufnr, entry)
      end
    end)
    return
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  pickers
    .new({}, {
      prompt_title = "Formatters",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display,
            ordinal = entry.display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.value then
            run_formatter(conform, bufnr, entry.value)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
