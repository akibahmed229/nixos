local caps = require("config.lsp.capabilities")

-- Php
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

vim.lsp.enable('phpls')
