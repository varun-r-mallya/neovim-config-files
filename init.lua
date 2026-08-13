-- bootstrap lazy.nvim, LazyVim and your plugins

-- Remap the legacy <Find> and <Select> strings back to Home and End
vim.keymap.set({'n', 'i', 'v'}, '<Find>', '<Home>', { silent = true })
vim.keymap.set({'n', 'i', 'v'}, '<Select>', '<End>', { silent = true })
require("config.lazy")
