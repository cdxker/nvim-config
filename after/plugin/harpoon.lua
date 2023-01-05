local term = require("harpoon.term")
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")


vim.keymap.set("n", "<leader>m", mark.add_file)
vim.keymap.set("n", "<S-m>", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>ta", function() term.gotoTerminal(1) end)
vim.keymap.set("n", "<leader>ts", function() term.gotoTerminal(2) end)
vim.keymap.set("n", "<leader>td", function() term.gotoTerminal(3) end)
vim.keymap.set("n", "<leader>tf", function() term.gotoTerminal(4) end)

vim.keymap.set("n", "<leader>ma", function() ui.nav_file(1) end)
vim.keymap.set("n", "<leader>ms", function() ui.nav_file(2) end)
vim.keymap.set("n", "<leader>md", function() ui.nav_file(3) end)
vim.keymap.set("n", "<leader>mf", function() ui.nav_file(4) end)
