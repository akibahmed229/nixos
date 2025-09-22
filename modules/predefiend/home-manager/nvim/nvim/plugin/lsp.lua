vim.lsp.config('*', {
    root_markers = { '.git' },
})

vim.diagnostic.config({
    virtual_text  = true,
    severity_sort = true,
    float         = {
        style  = 'minimal',
        border = 'rounded',
        source = 'if_many',
        header = '',
        prefix = '',
    },
    signs         = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN]  = '▲',
            [vim.diagnostic.severity.HINT]  = '⚑',
            [vim.diagnostic.severity.INFO]  = '»',
        },
    },
})
-- put early in lsp.lua
local orig = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts            = opts or {}
    opts.border     = opts.border or 'rounded'
    opts.max_width  = opts.max_width or 80
    opts.max_height = opts.max_height or 24
    opts.wrap       = opts.wrap ~= false
    return orig(contents, syntax, opts, ...)
end

-- 4) Per-buffer behavior on LSP attach (keymaps, auto-format, completion)
-- See :help LspAttach for the recommended pattern
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local buf    = args.buf
        local map    = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end

        -- Keymaps (use builtin LSP buffer functions)
        map('n', 'K', vim.lsp.buf.hover)
        map('n', 'gd', vim.lsp.buf.definition)
        map('n', 'gD', vim.lsp.buf.declaration)
        map('n', 'gi', vim.lsp.buf.implementation)
        map('n', 'go', vim.lsp.buf.type_definition)
        map('n', 'gr', vim.lsp.buf.references)
        map('n', 'gs', vim.lsp.buf.signature_help)
        map('n', 'gl', vim.diagnostic.open_float)
        map('n', '<F2>', vim.lsp.buf.rename)
        map({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end)
        map('n', '<F4>', vim.lsp.buf.code_action)

        -- Put near your LSP on_attach
        local excluded_filetypes = { php = true }

        -- Auto-format on save (only if server can't do WillSaveWaitUntil)
        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting')
            and not excluded_filetypes[vim.bo[buf].filetype]
        then
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
                buffer = buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

-- 5) Define the Lua language server config (no mason/lspconfig)
-- See :help lsp-new-config and :help vim.lsp.config()
local caps = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config['luals'] = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
    capabilities = caps,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
            },
            telemetry = { enable = false },
        },
    },
}

vim.lsp.config['cssls'] = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_markers = { 'package.json', '.git' },
    capabilities = caps,
    settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
    },
}

vim.lsp.config['phpls'] = {
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', '.git' },
    capabilities = caps,
    settings = {
        intelephense = {
            files = {
                maxSize = 5000000, -- default 5MB
            },
        },
    },
}

vim.lsp.config['ts_ls'] = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
        'javascript', 'javascriptreact', 'javascript.jsx',
        'typescript', 'typescriptreact', 'typescript.tsx',
    },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    capabilities = caps,
    settings = {
        completions = {
            completeFunctionCalls = true,
        },
    },
}

-- Nix LSP (nil)
vim.lsp.config['nil_ls'] = {
    cmd = { 'nil' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', 'default.nix', '.git' },
    capabilities = caps,
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixpkgs-fmt" } -- or "alejandra" if you prefer
            }
        }
    }
}


vim.lsp.enable('luals')
vim.lsp.enable('cssls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('phpls')
vim.lsp.enable('nil_ls')
