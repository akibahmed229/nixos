local caps = require("config.lsp.capabilities")

-- Get log directory safely without using the deprecated vim.lsp.get_log_path()
local log_dir = vim.fs.dirname(vim.lsp.log.get_filename())

-- Microsoft Roslyn Language Server (pkgs.roslyn-ls)
vim.lsp.config['roslyn'] = {
    cmd = {
        'Microsoft.CodeAnalysis.LanguageServer',
        '--stdio', -- Required flag to instruct Roslyn to communicate via standard I/O
        '--logLevel=Information',
        '--extensionLogDirectory=' .. log_dir,
    },
    filetypes = { 'cs' },
    root_markers = { '*.sln', '*.csproj', '.git' },
    capabilities = caps,
    settings = {
        ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
        },
        ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
        },
    },
}

vim.lsp.enable('roslyn')
