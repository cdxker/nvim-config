local lsp = require "lsp-zero".preset({
    name = "minimal",
    set_lsp_keymaps = true,
    manage_nvim_cmp = true,
    suggest_lsp_servers = true,
})

lsp.ensure_installed({
    "tsserver",
    "eslint",
    "rust_analyzer",
    "tailwindcss"
})


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-e>'] = cmp.mapping.scroll_docs(-4),
    ['<C-y>'] = cmp.mapping.scroll_docs(4),
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
    preselect = cmp.PreselectMode.Item
})


lsp.set_preferences({
    suggest_lsp_servers = true,
    sign_icons = {
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    if client.name == "eslint" then
        local format = vim.api.nvim_create_augroup("BufWritePost", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            command = "silent! lua vim.lsp.buf.format()",
            group = format,
        })
    end

    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("x", "<leader>a", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end)

lsp.configure('rust_analyzer', {
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
            cargo = {
                extraEnv = {
                    CC = "gcc-12",
                    CXX = "g++-12",
                }
            }
        },
    }
})

lsp.setup()

require "mason-null-ls".setup({
    automatic_installation = true,
    automatic_setup = true,
})

require "null-ls".setup()

vim.diagnostic.config({
    virtual_text = true,
})

local rt = require("rust-tools")
local mason_registry = require("mason-registry")

local codelldb = mason_registry.get_package("codelldb")
local extension_path = codelldb:get_install_path() .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"


local rust_lsp = lsp.build_options('rust_analyzer', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "K", rt.hover_actions.hover_actions, opts)
    vim.keymap.set("n", "<leader>t", rt.open_cargo_toml.open_cargo_toml, opts)
  end
})

rt.setup({
    dap = {
        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
    },
    server = rust_lsp
})
