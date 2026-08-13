-- Sui Move language support: LSP, syntax highlighting, formatting.

vim.lsp.config("move_analyzer", {
  cmd = { "move-analyzer" },
  filetypes = { "move" },
  root_markers = { "Move.toml", ".git" },
})
vim.lsp.enable("move_analyzer")

-- Nested .prettierrc files in some sui-repo subtrees (crates/sui-framework,
-- crates/sui, examples, ...) shadow the root prettier.config.js without
-- declaring the move plugin, so prettier can't infer the "move" parser
-- there. external-crates/move/tooling/prettier-move's own CLI works around
-- this by passing --plugin explicitly, same as scripts/lint.sh does.
local function find_prettier_move_tool(ctx)
  local matches = vim.fs.find("external-crates", { path = ctx.dirname, upward = true, type = "directory" })
  local external_crates = matches[1]
  if not external_crates then
    return nil
  end
  local tool_dir = external_crates .. "/move/tooling/prettier-move"
  if vim.uv.fs_stat(tool_dir .. "/bin/prettier-move.js") then
    return tool_dir
  end
  return nil
end

return {
  {
    "0xmovses/move.vim",
    ft = "move",
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        move = { "prettier_move" },
      },
      formatters = {
        prettier_move = {
          command = function(_, ctx)
            local tool_dir = find_prettier_move_tool(ctx)
            return tool_dir and (tool_dir .. "/bin/prettier-move.js") or "npx"
          end,
          args = function(_, ctx)
            if find_prettier_move_tool(ctx) then
              return { "--stdin-filepath", "$FILENAME" }
            end
            return { "--no-install", "prettier", "--stdin-filepath", "$FILENAME" }
          end,
          env = function(_, ctx)
            local tool_dir = find_prettier_move_tool(ctx)
            if not tool_dir then
              return nil
            end
            return { PATH = tool_dir .. "/node_modules/.bin:" .. (vim.env.PATH or "") }
          end,
          stdin = true,
        },
      },
    },
  },
}
