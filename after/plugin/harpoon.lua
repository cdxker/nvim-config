local term = require("harpoon.term")


vim.keymap.set("n", "<leader>ta", function() term.gotoTerminal(1) end)
vim.keymap.set("n", "<leader>ts", function() term.gotoTerminal(2) end)
vim.keymap.set("n", "<leader>td", function() term.gotoTerminal(3) end)
vim.keymap.set("n", "<leader>tf", function() term.gotoTerminal(4) end)
