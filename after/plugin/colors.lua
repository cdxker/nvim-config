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

require "rose-pine".setup ({
    variant = "dawn",
    dark_variant = "main",
})

color()
