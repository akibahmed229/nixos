local caps = require("config.lsp.capabilities")

-- Bash (bash-language-server)
vim.lsp.config['bashls'] = {
    cmd = { 'bash-language-server', 'start' },             -- standard command
    filetypes = { 'sh', 'bash' },                          -- filetypes to attach LSP
    root_markers = { '.git', '.bashrc', '.bash_profile' }, -- root detection
    capabilities = caps,
    settings = {},                                         -- bashls doesn’t require extra settings by default
}

vim.lsp.enable('bashls')
