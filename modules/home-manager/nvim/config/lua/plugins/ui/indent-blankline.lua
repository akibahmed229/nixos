return {
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
