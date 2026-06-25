local caps = require("config.lsp.capabilities")

-- 1. Dockerfile LSP
vim.lsp.config['dockerls'] = {
    -- Some versions of the nix package require 'docker-langserver'
    -- but you must ensure it points to the correct executable.
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
    -- Added more common Dockerfile names
    root_markers = { 'Dockerfile', 'Dockerfile.dev', '.git' },
    capabilities = caps,
}

-- 2. Docker Compose LSP
vim.lsp.config['docker-compose-ls'] = {
    cmd = { 'docker-compose-langserver', '--stdio' },
    filetypes = { 'yaml', 'yml' },
    -- Only attach if it looks like a compose file to avoid conflicts with yamlls
    root_markers = { 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml' },
    capabilities = caps,
}

vim.lsp.enable('dockerls')
vim.lsp.enable('docker-compose-ls')
