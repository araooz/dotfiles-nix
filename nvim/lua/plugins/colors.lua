return {
	-- 1. Instalar y configurar Nightfox (variante carbonfox)
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			options = {
				transparent = true, -- Cambia a false si prefieres el fondo oscuro nativo de carbonfox
			},
		},
	},

	-- 2. Indicarle a LazyVim que use "carbonfox" como tema por defecto
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "carbonfox",
		},
	},
}

