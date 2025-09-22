return {
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

}
