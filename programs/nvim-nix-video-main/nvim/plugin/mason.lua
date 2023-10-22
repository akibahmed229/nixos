require("mason").setup({ opts = {
      ensure_installed = {
        "clangd",
        "black",
        "pyright",
        "ruff",
        "pyright",
      },
},
})
