local caps = require("config.lsp.capabilities")

-- HTML/JSON
vim.lsp.config["htmlls"] = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "json", "jsonc" },
    root_markers = { ".git", "index.html" },
    capabilities = caps,
    settings = {
        html = {
            format = { enable = true },
            hover = { documentation = true, references = true },
        },
        json = { validate = true },
    },
}

vim.lsp.enable('htmlls')
