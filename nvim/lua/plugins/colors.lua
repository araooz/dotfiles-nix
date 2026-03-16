local function enable_transparency()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
end

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				transparent = true,
				terminal_colors = true,
				on_colors = function(colors)
					colors.bg = "#140b0c"
					colors.bg_dark = "#100809"
					colors.bg_float = "#100809"
					colors.bg_sidebar = "#100809"
					colors.bg_statusline = "#100809"
					colors.fg = "#f2d5d8"

					colors.red = "#ff5c7a"
					colors.orange = "#ff7a90"
					colors.yellow = "#ff9e8f"
					colors.green = "#e06c75"
					colors.cyan = "#f2a2b8"
					colors.blue = "#ff6f91"
					colors.magenta = "#ff5e9c"
					colors.purple = "#ff77b7"
				end,
				on_highlights = function(hl, colors)
					hl.CursorLine = { bg = "#241214" }
					hl.Visual = { bg = "#3a1b22" }
					hl.Search = { bg = "#ff5c7a", fg = colors.bg }
					hl.IncSearch = { bg = "#ff7a90", fg = colors.bg }
				end,
			})
			vim.cmd.colorscheme("tokyonight")
			enable_transparency()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			theme = "tokyonight",
		},
	},
}
