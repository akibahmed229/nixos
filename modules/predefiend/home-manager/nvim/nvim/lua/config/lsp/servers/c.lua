local caps = require("config.lsp.capabilities")

-- C / C++ (clangd)
vim.lsp.config['clangd'] = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
    capabilities = caps,
    settings = {
        clangd = {
            fallbackFlags = { "-std=c++20" },
        },
    },
}

vim.lsp.enable('clangd')
