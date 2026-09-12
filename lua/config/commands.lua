-- nvim 0.12 ships a native `:lsp` command, which makes nvim-lspconfig's plugin
-- file return early and skip defining :LspInfo / :LspLog / :LspRestart.
-- These restore the old names on top of the native commands.

vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {
  desc = "Alias to `:checkhealth vim.lsp`",
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("tabnew " .. vim.fn.fnameescape(vim.lsp.log.get_filename()))
end, { desc = "Open the LSP client log in a new tab" })

local function lsp_alias(name, sub, desc)
  vim.api.nvim_create_user_command(name, function(opts)
    local args = opts.args ~= "" and (" " .. opts.args) or ""
    vim.cmd("lsp " .. sub .. args)
  end, { nargs = "*", desc = desc })
end

lsp_alias("LspStart", "enable", "Enable and launch a language server")
lsp_alias("LspStop", "stop", "Stop the given language client(s)")
lsp_alias("LspRestart", "restart", "Restart the given language client(s)")
