return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            -- Snippets
            'saadparwaiz1/cmp_luasnip',
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            require('luasnip.loaders.from_vscode').lazy_load()
            vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

            cmp.setup({
                preselect = cmp.PreselectMode.Item, -- <— preselect first item
                completion = { completeopt = "menu,menuone,noinsert" },
                window = { documentation = cmp.config.window.bordered() },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<C-Space>"] = cmp.mapping.complete(), -- manual trigger if you want it
                    ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item() else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"]   = cmp.mapping(function()
                        if cmp.visible() then cmp.select_prev_item() end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = 'luasnip', keyword_length = 2 },
                    { name = "buffer",  keyword_length = 3 },
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
            })
        end,
    },
}
