return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        priority = 1000, -- Load early to prevent runtime query conflicts
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.config").setup({
                ensure_installed = {
                    "json", "python", "javascript", "query", "typescript",
                    "tsx", "php", "yaml", "html", "css", "markdown", "c_sharp",
                    "markdown_inline", "bash", "lua", "vim", "vimdoc",
                    "c", "dockerfile", "gitignore", "astro", "nix",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                    },
                },
            })
        end,
    },
}
