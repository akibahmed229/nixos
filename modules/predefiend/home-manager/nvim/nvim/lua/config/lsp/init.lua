-- Entry point: load core and all servers
require("config.lsp.core")


-- Load servers
local servers = {
    "lua", "css", "html", "php", "ts",
    "nix", "c", "python", "dart",
    "rust", "bash", "yaml", "terraform"
}

for _, s in ipairs(servers) do
    require("config.lsp.servers." .. s)
end
