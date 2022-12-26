function color(color)
    my_color = color or "dracula"
    vim.cmd.colorscheme(my_color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    require('indent_blankline').setup {
        char = '┊',
        show_trailing_blankline_indent = false,
    }

    require "lualine".setup {
        -- Disable sections and component separators
        options = {
            theme = my_color,
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
        },
    }
end

color()
