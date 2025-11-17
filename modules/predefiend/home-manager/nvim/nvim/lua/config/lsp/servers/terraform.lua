local caps = require("config.lsp.capabilities")

vim.lsp.config['terraformls'] = {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "tf", "tfvars" },
    root_markers = { ".terraform", ".git" },
    capabilities = caps,
}

vim.lsp.enable("terraformls")
