local caps = require("config.lsp.capabilities")

-- Dart (for Flutter)
vim.lsp.config['dartls'] = {
    cmd = { 'dart', 'language-server', '--protocol=lsp' },
    filetypes = { 'dart' },
    root_markers = { 'pubspec.yaml', '.git' },
    capabilities = caps,
    settings = {
        dart = {
            completeFunctionCalls = true,
            analysisExcludedFolders = { "build" },
        },
    },
}

vim.lsp.enable('dartls')
