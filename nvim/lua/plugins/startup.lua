return {
	"goolord/alpha-nvim",
	opts = function()
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"███╗   ██╗██╗   ██╗██╗███╗   ███╗",
			"████╗  ██║██║   ██║██║████╗ ████║",
			"██╔██╗ ██║██║   ██║██║██╔████╔██║",
			"██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
			"██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
			"╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "  Nuevo archivo", ":ene <BAR> startinsert <CR>"),
			dashboard.button("c", "  Abrir ~/.config/", ":cd ~/.config/ <BAR> e .<CR>"),
			dashboard.button("n", "  Abrir ~/.config/nvim/", ":cd ~/.config/nvim/ <BAR> e .<CR>"),
			dashboard.button("h", "  Abrir ~/.config/hypr/", ":cd ~/.config/hypr/ <BAR> e .<CR>"),
			dashboard.button("w", "  Abrir ~/.config/waybar/", ":cd ~/.config/waybar/ <BAR> e .<CR>"),
			dashboard.button("z", "  Abrir home.nix", ":cd ~/.config/nix/ <BAR> e home.nix<CR>"),
			dashboard.button("q", "  Salir", ":qa<CR>"),
		}

		return dashboard
	end,
}
