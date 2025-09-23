local caps = require("config.lsp.capabilities")

-- Rust (rust_analyzer)
vim.lsp.config['rust_analyzer'] = {
    cmd = { 'rust-analyzer' },               -- correct Rust LSP binary
    filetypes = { 'rust' },                  -- Rust filetypes
    root_markers = { 'Cargo.toml', '.git' }, -- project root detection
    capabilities = caps,
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true, -- enable all features
            },
            checkOnSave = {
                command = 'clippy', -- run clippy on save
            },
        },
    },
}

vim.lsp.enable('rust_analyzer')
