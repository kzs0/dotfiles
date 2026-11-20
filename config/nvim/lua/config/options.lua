-- Options are automatically loaded before lazy.nvim startup.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Mac-style shift selection: Shift + arrows / Home / End (and option/cmd
-- variants, see keymaps.lua) select text, typing replaces it, an unshifted
-- arrow ends it.
vim.opt.keymodel = { "startsel", "stopsel" }
vim.opt.selectmode = { "key" }

vim.opt.relativenumber = true
