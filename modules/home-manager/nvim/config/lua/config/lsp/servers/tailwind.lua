local caps = require("config.lsp.capabilities")

-- Add this for Tailwind
vim.lsp.config['tailwind_ls'] = {
    cmd = { 'tailwindcss-language-server', '--stdio' },
    filetypes = {
        'javascript', 'javascriptreact', 'javascript.jsx',
        'typescript', 'typescriptreact', 'typescript.tsx',
    },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    capabilities = caps, -- Use your existing capabilities
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    -- This helps Tailwind find class strings in common Next.js patterns
                    { "tw`([^`]*)`",            "tw" },
                    { "className=\"([^\"]*)\"", "className" },
                },
            },
        },
    },
}
vim.lsp.enable("tailwind_ls")
