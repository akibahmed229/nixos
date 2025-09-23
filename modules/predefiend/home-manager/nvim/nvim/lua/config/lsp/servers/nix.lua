local caps = require("config.lsp.capabilities")

-- Nix LSP (nixd)
vim.lsp.config['nixd_ls'] = {
    cmd = { 'nixd' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', 'default.nix', '.git' },
    capabilities = caps,
    settings = {
        ['nixd'] = {
            formatting = {
                command = { "alejandra" } -- or "alejandra" if you prefer
            }
        }
    }
}

vim.lsp.enable('nixd_ls')
