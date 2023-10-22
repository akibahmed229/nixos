require("mason-lspconfig").setup {
      ensure_installed = {
        "clangd",
        "black",
        "pyright",
        "ruff",
        "pyright",
      },
}
