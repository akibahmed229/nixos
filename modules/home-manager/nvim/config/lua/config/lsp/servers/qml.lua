local caps = require("config.lsp.capabilities")

-- QML (qml-language-server)
vim.lsp.config['qmlls'] = {
    cmd = { 'qmlls' },
    filetypes = { 'qml' },
    root_markers = { '.git', 'qmldir', 'CMakeLists.txt' }, -- Added qmldir for better detection
    capabilities = caps,
    -- Cleaned up the settings block (removed invalid yaml entry)
    settings = {
        qml = {
            format = {
                enable = true,
            },
        },
    },
}

vim.lsp.enable('qmlls')
