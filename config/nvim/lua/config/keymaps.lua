-- Keymaps are automatically loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Mac-style movement. Ghostty and Rex send:
--   option+left/right        ESC b / ESC f      → <M-b> / <M-f>
--   cmd+left/right           Home / End         (native)
--   option+backspace         ESC DEL            → <M-BS>
--   cmd+backspace            ctrl-u             (native in insert mode)
--   shift+…                  <S-Left> <S-Home> <M-S-Left> …  → select
local map = vim.keymap.set

-- word jumps
map({ "n", "x", "o" }, "<M-b>", "b", { desc = "Word back" })
map({ "n", "x", "o" }, "<M-f>", "e", { desc = "Word forward (end)" })
map("i", "<M-b>", "<C-o>b", { desc = "Word back" })
map("i", "<M-f>", "<C-o>e<Right>", { desc = "Word forward (end)" })
map("c", "<M-b>", "<S-Left>", { desc = "Word back" })
map("c", "<M-f>", "<S-Right>", { desc = "Word forward" })

-- delete word / line backwards
map({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Delete word back" })

-- shift+option selects by word (reuses 'keymodel' via the shifted ctrl-arrow)
map({ "n", "i", "s", "x" }, "<M-S-Left>", "<S-C-Left>", { remap = true, desc = "Select word back" })
-- forward selects to the *end* of the word, like macOS (shift-ctrl-right would grab the next word's first char)
map("n", "<M-S-Right>", "ve<C-g>", { desc = "Select word forward" })
map("i", "<M-S-Right>", "<C-o>ve<C-g>", { desc = "Select word forward" })
map("s", "<M-S-Right>", "<C-o>e", { desc = "Select word forward" })
map("x", "<M-S-Right>", "e", { desc = "Select word forward" })

-- Backspace deletes a shift-selection (Select mode already replaces on typing)
map("s", "<BS>", "<C-g>\"_d", { desc = "Delete selection" })
