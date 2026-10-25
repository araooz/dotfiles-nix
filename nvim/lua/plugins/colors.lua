-- colores generados por nix/theme.nix
local ok, c = pcall(require, "theme_colors")
if not ok then
	c = { bg = "#000000", bgAlt = "#0d0d0d", surface = "#1a1a1a", overlay = "#2e2e2e", accent = "#e0afff" }
end

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
			-- fondo negro como el resto del sistema
			palettes = {
				carbonfox = {
					bg0 = c.bgAlt, -- barras laterales, statusline, flotantes
					bg1 = c.bg, -- fondo principal
					bg2 = c.surface, -- cursorline, menus
					bg3 = c.overlay,
					sel0 = c.surface, -- seleccion en menus
					sel1 = c.overlay,
				},
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

