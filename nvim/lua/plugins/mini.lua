return {
    {
        "echasnovski/mini.nvim",
        version = false,
        event = "VeryLazy",
        config = function()
            -- Módulo de comentarios (reemplaza a comment.nvim)
            require("mini.comment").setup()

            -- Paréntesis y comillas automáticas (reemplaza a autopairs)
            require("mini.pairs").setup()
        end,
    },
}
