return {
    -- Rainbow Delimiters: Colorea llaves y paréntesis anidados
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = {
                    [""] = rainbow_delimiters.strategy["global"],
                },
            }
        end,
    },

    -- Modes: Cambia el color de la línea del cursor según el modo de Vim
    {
        "mvllow/modes.nvim",
        event = "VeryLazy",
        opts = {
            colors = {
                copy = "#f5c2e7",
                delete = "#f38ba8",
                insert = "#a6e3a1",
                visual = "#5430ff",
            },
            line_opacity = 0.30,
        },
    },

    -- Snacks: Colección de utilidades modernas y rápidas
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            notifier = { enabled = true, timeout = 2000 },
            quickfile = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
        },
    },
}
