local caps = require("config.lsp.capabilities")

-- YAML (yaml-language-server)
vim.lsp.config['yamlls'] = {
    cmd = { 'yaml-language-server', '--stdio' }, -- standard command for yaml-ls
    filetypes = { 'yaml', 'yml' },               -- attach to YAML files
    root_markers = { '.git', '.yamllint' },      -- root detection
    capabilities = caps,
    settings = {
        yaml = {
            schemas = {},      -- add schema mappings if needed
            validate = true,   -- enable validation
            completion = true, -- enable completion suggestions
        },
    },
}


vim.lsp.enable('yamlls')
