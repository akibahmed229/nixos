local caps = require("config.lsp.capabilities")

-- YAML (yaml-language-server)
vim.lsp.config['yamlls'] = {
    cmd = { 'yaml-language-server', '--stdio' }, -- standard command for yaml-ls
    filetypes = { 'yaml', 'yml' },               -- attach to YAML files
    root_markers = { '.git', '.yamllint' },      -- root detection
    capabilities = caps,
    settings = {
        yaml = {
            -- This enables automatic schema detection
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
                -- Manually link GHA if it doesn't auto-detect
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
            },
            validate = true,   -- enable validation
            completion = true, -- enable completion suggestions
        },
    },
}


vim.lsp.enable('yamlls')
