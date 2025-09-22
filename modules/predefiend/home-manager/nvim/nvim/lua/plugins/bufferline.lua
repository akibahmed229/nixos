return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy", -- load lazily but not too late
        keys = {
            { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
            { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous Buffer" },
            { "<leader>bd", "<Cmd>bdelete<CR>",             desc = "Delete Buffer" },
        },
        config = function()
            require("bufferline").setup({
                options = {
                    numbers = "none",
                    diagnostics = "nvim_lsp",  -- shows LSP diagnostics in bufferline
                    separator_style = "slant", -- "slant" | "thick" | "thin"
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    always_show_bufferline = true,
                },
            })
        end,
    },
}
