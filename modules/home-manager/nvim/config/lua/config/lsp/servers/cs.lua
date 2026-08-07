-- config/lua/config/lsp/servers/cs.lua
local caps = require("config.lsp.capabilities")

require("roslyn").setup({
    exe = "Microsoft.CodeAnalysis.LanguageServer", -- resolved via $PATH, from roslyn-ls Nix package
    capabilities = caps,
    config = {
        settings = {
            ["csharp|background_analysis"] = {
                dotnet_analyzer_diagnostics_scope = "fullSolution",
                dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|code_lens"] = {
                dotnet_enable_references_code_lens = true,
            },
        },
    },
    filewatching = "roslyn",
    broad_search = true, -- finds REST.API.csproj with no .sln present
})
