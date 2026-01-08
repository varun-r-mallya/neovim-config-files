-- ~/.config/nvim/after/ftplugin/c.lua

-- Get the current directory
local path = vim.fn.expand("%:p:h")

-- Check if we are inside a linux kernel tree (looks for Kbuild or specific folders)
-- You can also check if the path contains "linux" or "kernel"
if path:find("linux") or vim.fn.filereadable("Kbuild") == 1 or vim.fn.filereadable("Makefile") == 1 then
  vim.opt_local.tabstop = 8
  vim.opt_local.shiftwidth = 8
  vim.opt_local.softtabstop = 8
  vim.opt_local.expandtab = false -- Force hard tabs
  vim.opt_local.cindent = true
  vim.opt_local.colorcolumn = "80,100"
end
