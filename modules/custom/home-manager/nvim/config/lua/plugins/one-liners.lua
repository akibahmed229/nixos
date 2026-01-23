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

    -- Enable autopairs
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
}
