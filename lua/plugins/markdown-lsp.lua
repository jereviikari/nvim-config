local function is_codex_prompt_markdown(bufnr)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  return filename:match("^%.tmp.*%.md$") ~= nil
end

-- Prevent Marksman from attaching to Codex prompt buffers; Markdown lint warnings are toggled via diagnostics.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          root_dir = function(bufnr, on_dir)
            if is_codex_prompt_markdown(bufnr) then
              return
            end

            -- Prefer the nearest repo over ~/.marksman.toml, which otherwise makes Marksman scan all of $HOME.
            local root = vim.fs.root(bufnr, ".git")
            local home = vim.uv.os_homedir()

            if not root then
              local marksman_root = vim.fs.root(bufnr, ".marksman.toml")
              if marksman_root and marksman_root ~= home and marksman_root ~= "/" then
                root = marksman_root
              end
            end

            if not root then
              local dirname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
              if dirname ~= home and dirname ~= "/" then
                root = dirname
              end
            end

            if root then
              on_dir(root)
            end
          end,
        },
      },
    },
  },
}
