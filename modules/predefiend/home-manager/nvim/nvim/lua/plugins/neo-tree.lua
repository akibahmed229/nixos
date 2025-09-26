return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- optional, but recommended
        },
        lazy = false,                      -- neo-tree will lazily load itself
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = false, -- auto close if it's the last window
                filesystem = {
                    follow_current_file = {
                        enabled = true,                     -- syncs with your current buffer
                    },
                    hijack_netrw_behavior = "open_default", -- replace netrw
                },
            })
        end,
    }
}
