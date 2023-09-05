-- Example config in lua
vim.g.nord_contrast = true
vim.g.nord_borders = true
vim.g.nord_disable_background = false
vim.g.nord_italic = true
vim.g.nord_uniform_diff_background = true
vim.g.nord_bold = true

function color(color)
    my_color = color or "gruvbox-baby"
    vim.cmd.colorscheme(my_color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    require('indent_blankline').setup {
        char = '┊',
        show_trailing_blankline_indent = false,
    }
end

require "rose-pine".setup({
    variant = "dawn",
    dark_variant = "main",
})

color()
