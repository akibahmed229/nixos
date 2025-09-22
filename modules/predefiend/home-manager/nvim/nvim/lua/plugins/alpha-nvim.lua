return {
    {
        "goolord/alpha-nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/persistence.nvim",
        },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Custom ASCII art header
            dashboard.section.header.val = {
                "                                                                       ",
                "                                                                       ",
                "                                                                       ",
                "                                                                       ",
                "                                                                     ",
                "       ████ ██████           █████      ██                     ",
                "      ███████████             █████                             ",
                "      █████████ ███████████████████ ███   ███████████   ",
                "     █████████  ███    █████████████ █████ ██████████████   ",
                "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
                "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
                " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
                "                                                                       ",
                "                                                                       ",
                "                                                                       ",
                "                       git@github.com:akibahmed229                     ",
            }

            -- Buttons
            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
                dashboard.button("n", "  New File", ":ene <BAR> startinsert<CR>"),
                dashboard.button("r", "󰈚  Recent Files", ":Telescope oldfiles<CR>"),
                dashboard.button("g", "󰈭  Find Word", ":Telescope live_grep<CR>"),
                dashboard.button("s", "  Restore Session", ":lua require('persistence').load()<CR>"),
                dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
            }

            -- Padding and layout
            dashboard.config.layout = {
                { type = "padding", val = 4 },
                dashboard.section.header,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
            }

            alpha.setup(dashboard.opts)
        end,
    },
}
