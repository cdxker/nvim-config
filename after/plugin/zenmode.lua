vim.keymap.set("n", "<leader>gg", function()
    require("zen-mode").setup {
        on_open = function(win)
            vim.cmd("setlocal winblend=0")
            vim.cmd("setlocal spell! spelllang=en_us")
            vim.cmd("setlocal noexpandtab")
            vim.cmd("map j gj")
            vim.cmd("map k gk")
            vim.cmd("map $ g$")
            vim.cmd("map 0 g0")
            vim.opt.wrap = true
        end,
        on_close = function(win)
            vim.opt.wrap = false
            vim.cmd("setlocal spell! spelllang=en_us")
        end
    }
    require("zen-mode").toggle()
    color()
end)

