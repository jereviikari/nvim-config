local M = {}

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

local function trim(text)
  return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function oneline(text, max_len)
  text = trim(text):gsub("%s+", " ")
  if #text > max_len then
    return text:sub(1, max_len - 3) .. "..."
  end
  return text
end

local function get_root()
  local ok, root = pcall(function()
    return LazyVim.root()
  end)

  if ok and root and root ~= "" then
    return root
  end

  return vim.fn.getcwd()
end

local function relative_path(path, cwd)
  local normalized_path = vim.fs.normalize(path)
  local normalized_cwd = vim.fs.normalize(cwd):gsub("/$", "")
  local prefix = normalized_cwd .. "/"

  if normalized_path:sub(1, #prefix) == prefix then
    return normalized_path:sub(#prefix + 1)
  end

  return vim.fn.fnamemodify(path, ":.")
end

local function diagnostic_source(diagnostic)
  local parts = {}

  if diagnostic.source and diagnostic.source ~= "" then
    table.insert(parts, diagnostic.source)
  end

  if diagnostic.code and diagnostic.code ~= "" then
    table.insert(parts, tostring(diagnostic.code))
  end

  if #parts == 0 then
    return ""
  end

  return " " .. table.concat(parts, "/")
end

local function sort_diagnostics(diagnostics)
  table.sort(diagnostics, function(a, b)
    local a_file = a.relative or ""
    local b_file = b.relative or ""

    if a_file ~= b_file then
      return a_file < b_file
    end

    local a_diagnostic = a.diagnostic or a
    local b_diagnostic = b.diagnostic or b

    if a_diagnostic.lnum == b_diagnostic.lnum then
      return (a_diagnostic.col or 0) < (b_diagnostic.col or 0)
    end
    return (a_diagnostic.lnum or 0) < (b_diagnostic.lnum or 0)
  end)
end

local function append_diagnostic(prompt, diagnostic, relative, lines)
  local line = (diagnostic.lnum or 0) + 1
  local col = (diagnostic.col or 0) + 1
  local severity = severity_names[diagnostic.severity] or "UNKNOWN"
  local message = oneline(diagnostic.message, 220)
  local source = diagnostic_source(diagnostic)
  local code = lines and oneline(lines[line] or "", 180) or ""

  table.insert(prompt, ("- %s:%d:%d [%s%s] %s"):format(relative, line, col, severity, source, message))
  if code ~= "" then
    table.insert(prompt, "  Code: " .. code)
  end
end

local function append_review_instructions(prompt)
  vim.list_extend(prompt, {
    "",
    "Instructions:",
    "- Inspect the file and surrounding code before suggesting changes.",
    "- Group similar diagnostics by root cause or fix type.",
    "- Present one group at a time.",
    "- For each group, summarize the affected diagnostics and give a concrete fixing suggestion.",
    "- Ask for confirmation before applying the fixes for that group.",
    "- After I approve a group, apply only that group's focused changes.",
    "- Then continue with the next group and ask again.",
    "- Do not make unrelated refactors.",
    "- Run the relevant formatter or checks only after applying approved changes, when practical.",
    "- Report anything that remains unresolved.",
  })
end

local function build_file_prompt(bufnr, cwd, filename, diagnostics)
  local relative = relative_path(filename, cwd)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local prompt = {
    "Review the diagnostics reported by Neovim for this file.",
    "Do not apply changes until I explicitly approve them.",
    "",
    "Working root: " .. cwd,
    "File: " .. relative,
    "",
    "Diagnostics:",
  }

  sort_diagnostics(diagnostics)

  local max_diagnostics = 80
  for i = 1, math.min(#diagnostics, max_diagnostics) do
    append_diagnostic(prompt, diagnostics[i], relative, lines)
  end

  if #diagnostics > max_diagnostics then
    table.insert(prompt, ("- %d more diagnostics omitted from this prompt."):format(#diagnostics - max_diagnostics))
  end

  append_review_instructions(prompt)

  return table.concat(prompt, "\n")
end

local function collect_workspace_diagnostics(cwd)
  local diagnostics = {}
  local modified = {}
  local seen_modified = {}
  local buffers = {}

  for _, diagnostic in ipairs(vim.diagnostic.get(nil)) do
    local bufnr = diagnostic.bufnr

    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      local buffer = buffers[bufnr]

      if not buffer then
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local loaded = filename ~= "" and vim.api.nvim_buf_is_loaded(bufnr)

        buffer = {
          filename = filename,
          loaded = loaded,
          lines = loaded and vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) or nil,
          modified = loaded and vim.bo[bufnr].modified,
          relative = filename ~= "" and relative_path(filename, cwd) or nil,
        }
        buffers[bufnr] = buffer
      end

      if buffer.relative then
        if buffer.modified and not seen_modified[buffer.relative] then
          table.insert(modified, buffer.relative)
          seen_modified[buffer.relative] = true
        end

        table.insert(diagnostics, {
          diagnostic = diagnostic,
          relative = buffer.relative,
          lines = buffer.lines,
        })
      end
    end
  end

  table.sort(modified)
  return diagnostics, modified
end

local function build_workspace_prompt(cwd, diagnostics)
  local prompt = {
    "Review the diagnostics currently known to Neovim for this workspace.",
    "These come from Neovim's diagnostic store, equivalent to vim.diagnostic.get(nil).",
    "They may include only diagnostics already reported by active LSPs or linters.",
    "Do not assume this is a complete whole-project lint result.",
    "Do not apply changes until I explicitly approve them.",
    "",
    "Working root: " .. cwd,
    "",
    "Diagnostics:",
  }

  sort_diagnostics(diagnostics)

  local max_diagnostics = 160
  for i = 1, math.min(#diagnostics, max_diagnostics) do
    local entry = diagnostics[i]
    append_diagnostic(prompt, entry.diagnostic, entry.relative, entry.lines)
  end

  if #diagnostics > max_diagnostics then
    table.insert(prompt, ("- %d more diagnostics omitted from this prompt."):format(#diagnostics - max_diagnostics))
  end

  append_review_instructions(prompt)

  return table.concat(prompt, "\n")
end

local function build_file_context_prompt(cwd, filename)
  local relative = relative_path(filename, cwd)
  local cursor = vim.api.nvim_win_get_cursor(0)

  return table.concat({
    "Open this project and file as context for my next prompt.",
    "",
    "Working root: " .. cwd,
    "File: " .. relative,
    ("Cursor: %s:%d:%d"):format(relative, cursor[1], cursor[2] + 1),
    "",
    "Instructions:",
    "- Inspect the file and surrounding code before answering.",
    "- Do not apply changes unless I explicitly ask you to.",
    "- Wait for my next prompt.",
  }, "\n")
end

local function copy_prompt(prompt)
  if vim.fn.has("clipboard") == 1 then
    local ok = pcall(vim.fn.setreg, "+", prompt)
    if ok then
      return "clipboard"
    end
  end

  pcall(vim.fn.setreg, '"', prompt)
  return "default register"
end

local function open_codex(cwd, prompt)
  local cmd = { "codex", "-C", cwd, prompt }

  if Snacks and Snacks.terminal then
    Snacks.terminal(cmd, { cwd = cwd })
    return
  end

  vim.cmd("botright split")
  vim.cmd("resize 18")
  vim.fn.termopen(cmd, { cwd = cwd })
  vim.cmd("startinsert")
end

local function send_to_codex(cwd, prompt, prompt_name)
  local copy_target = copy_prompt(prompt)

  if vim.fn.executable("codex") ~= 1 then
    vim.notify(("Codex CLI not found. %s copied to %s."):format(prompt_name, copy_target), vim.log.levels.WARN)
    return
  end

  open_codex(cwd, prompt)
  vim.notify(("%s sent to Codex and copied to %s"):format(prompt_name, copy_target))
end

function M.open_file_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    vim.notify("Save this buffer before opening Codex with file context", vim.log.levels.WARN)
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("Save this buffer first so Codex sees the same file contents", vim.log.levels.WARN)
    return
  end

  local cwd = get_root()
  local prompt = build_file_context_prompt(cwd, filename)
  send_to_codex(cwd, prompt, "File context prompt")
end

function M.fix_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    vim.notify("Save this buffer before asking Codex to fix diagnostics", vim.log.levels.WARN)
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("Save this buffer first so Codex sees the same file contents", vim.log.levels.WARN)
    return
  end

  local diagnostics = vim.diagnostic.get(bufnr)
  if #diagnostics == 0 then
    vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
    return
  end

  local cwd = get_root()
  local prompt = build_file_prompt(bufnr, cwd, filename, diagnostics)
  send_to_codex(cwd, prompt, "File diagnostic prompt")
end

function M.fix_workspace_diagnostics()
  local cwd = get_root()
  local diagnostics, modified = collect_workspace_diagnostics(cwd)

  if #diagnostics == 0 then
    vim.notify("No workspace diagnostics known to Neovim", vim.log.levels.INFO)
    return
  end

  if #modified > 0 then
    local shown = vim.list_slice(modified, 1, 5)
    local suffix = #modified > #shown and (" and " .. (#modified - #shown) .. " more") or ""
    vim.notify("Save modified buffers first: " .. table.concat(shown, ", ") .. suffix, vim.log.levels.WARN)
    return
  end

  local prompt = build_workspace_prompt(cwd, diagnostics)
  send_to_codex(cwd, prompt, "Workspace diagnostic prompt")
end

return M
