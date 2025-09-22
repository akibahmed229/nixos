return {
    -- This helps with php/html for indentation
    {
        'captbaritone/better-indent-support-for-php-with-html',
    },

    -- This helps with ssh tunneling and copying to clipboard
    {
        'ojroques/vim-oscyank',
    },

    -- This generates docblocks
    {
        'kkoomen/vim-doge',
        build = ':call doge#install()'
    },

    -- Git plugin
    {
        'tpope/vim-fugitive',
    },

    -- Show historical versions of the file locally
    {
        'mbbill/undotree',
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>ut", "<cmd>UndotreeToggle<CR>" },
        },
    },

    -- Show CSS Colors
    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },

    -- Show keybinds
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    -- Enable autopairs
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

    -- Enable Tmux navigator
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
            "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },

    -- Enable session management for Neovim
    {
        "folke/persistence.nvim",
        event = "BufReadPre", -- this will only start session saving when an actual file was opened
        config = function()
            require("persistence").setup {
                dir = vim.fn.stdpath("state") .. "/sessions/", -- where to save sessions
                options = { "buffers", "curdir", "tabpages", "winsize" },
            }
        end,
    },

    --  Indent guides for Neovim
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            -- basic indent-blankline options (optional)
            char = "│",
            show_trailing_blankline_indent = true,
            show_current_context = true,
        },
        config = function()
            require("ibl").setup()
        end
    }
}
