return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                python   = { "black" },
                html     = { "prettier" },
                json     = { "prettier" },
                css      = { "prettier" },
                yaml     = { "prettier" },
                markdown = { "prettier" },
            },
        })

        -- Auto-format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function(args)
                require("conform").format({ bufnr = args.buf })
            end,
        })
    end,
}
