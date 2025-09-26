return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy", -- load lazily but not too late
        keys = {
            { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
            { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous Buffer" },
            { "<leader>bd", "<Cmd>bdelete<CR>",             desc = "Delete Buffer" }
        },
        config = function()
            require("bufferline").setup({
                options = {
                    numbers = "none",
                    diagnostics = "nvim_lsp", -- shows LSP diagnostics in bufferline
                    separator_style = "thin", -- "slant" | "thick" | "thin"
                    show_buffer_close_icons = true,
                    show_close_icon = true,
                    always_show_bufferline = true,
                    indicator = { style = 'underline' }, -- highlights current buffer with underline
                    offsets = {
                        {
                            filetype = "neo-tree",   -- detect the Neo-tree window
                            text = "Explorer",       -- optional label (shown in the empty space)
                            highlight = "Directory", -- highlight group for the label
                            text_align = "left",     -- "left" | "center" | "right"
                            separator = true,        -- add a vertical separator between neo-tree and buffers
                        },
                    },
                },
                highlights = {
                    -- change background/foreground for active buffer
                    buffer_selected = {
                        fg = "#ffffff",
                        -- bg = "#8ec07c",
                        bold = true,
                    },
                },
            })
        end,
    },
}
