local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<C-_>', builtin.live_grep, {})
vim.keymap.set('n', '<C-;>', builtin.live_grep, {})
