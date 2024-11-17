require "mason".setup()
require("mason-lspconfig").setup()

vim.filetype.add({
    extension = {
        gotmpl = 'gotmpl',
        mdx    = 'mdx',
    },
    pattern = {
        [".*/templates/.*%.tpl"] = "helm",
        [".*/templates/.*%.ya?ml"] = "helm",
        ["helmfile.*%.ya?ml"] = "helm",
    },
})

--
-- function lspPls(R)
--     require"lspconfig".rust_analyzer.setup {
--         settings = {
--             ["rust-analyzer"] = {
--                 check = {
--                     command = "clippy",
--                 },
--             },
--         }
--     }
--
--     require"lspconfig".rust_analyzer.setup {
--         settings = {
--             ["rust-analyzer"] = {
--                 check = {
--                     command = "clippy",
--                 },
--             },
--         }
--     }
--


local lsp = require "lsp-zero".preset({
    name = "minimal",
    set_lsp_keymaps = true,
    manage_nvim_cmp = true,
    suggest_lsp_servers = true,
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
})

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-e>'] = cmp.mapping.scroll_docs(-4),
        ['<C-y>'] = cmp.mapping.scroll_docs(4),
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = nil,
        ['<S-Tab>'] = nil,
    })
})

lsp.set_preferences({
    suggest_lsp_servers = true,
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- if client.name == "eslint" then
    --     local format = vim.api.nvim_create_augroup("BufWritePost", { clear = true })
    --     vim.api.nvim_create_autocmd("BufWritePre", {
    --         command = "silent! lua vim.lsp.buf.format()",
    --         group = format,
    --     })
    -- end


    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
end)

local rt = require("rust-tools")

lsp.configure("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    }
})

local M = {
  k8s_schemas = {
    {
      name = 'Kubernetes 1.27.12',
      uri = 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.12-standalone-strict/all.json',
    },
    {
      name = 'Kubernetes 1.26.14',
      uri = 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.26.14-standalone-strict/all.json',
    },
  },
  all_schemas = {},
}

local yaml_cfg = require('yaml-companion').setup {
    builtin_matchers = {
        -- Detects Kubernetes files based on content
        kubernetes = { enabled = true },
    },
    schemas = M.all_schemas,
}

lsp.configure("yamlls", {
    yaml_cfg
})


lsp.setup()

local rust_lsp = lsp.build_options('rust_analyzer', {
    single_file_support = false,
    on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "K", rt.hover_actions.hover_actions, opts)
        vim.keymap.set("n", "<leader>t", rt.open_cargo_toml.open_cargo_toml, opts)
    end
})

vim.diagnostic.config({
    virtual_text = true,
})

vim.api.nvim_set_keymap('i', '<M-CR>', 'copilot#Accept("<CR>")', { expr=true, noremap = true, silent = true })
vim.g.copilot_no_tab_map = true

-- local mason_registry = require("mason-registry")
--
-- local codelldb = mason_registry.get_package("codelldb")
-- local extension_path = codelldb:get_install_path() .. "/extension/"
-- local codelldb_path = extension_path .. "adapter/codelldb"
-- local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
