return {
	-- ── Render Markdown: visualización bonita dentro del buffer ──────────
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
		opts = {
			heading = {
				sign = false,
				icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
				backgrounds = {
					"RenderMarkdownH1Bg",
					"RenderMarkdownH2Bg",
					"RenderMarkdownH3Bg",
					"RenderMarkdownH4Bg",
					"RenderMarkdownH5Bg",
					"RenderMarkdownH6Bg",
				},
			},
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
				language_pad = 1,
				border = "thin",
			},
			bullet = {
				icons = { "●", "○", "◆", "◇" },
			},
			checkbox = {
				enabled = true,
				unchecked = { icon = "  " },
				checked = { icon = "  " },
				custom = {
					todo = { raw = "[-]", rendered = "  ", highlight = "RenderMarkdownTodo" },
				},
			},
			pipe_table = {
				style = "full",
				cell = "padded",
			},
			link = {
				enabled = true,
				hyperlink = "󰌹 ",
				image = "󰋩 ",
			},
		},
	},

	-- ── Zen Mode: escritura sin distracciones con <leader>z ─────────────
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		keys = {
			{ "<leader>z", "<cmd>ZenMode<cr>", desc = "Modo Zen (escritura enfocada)" },
		},
		opts = {
			window = {
				backdrop = 0.93,
				width = 90,
				height = 0.9,
				options = {
					signcolumn = "no",
					number = false,
					relativenumber = false,
					cursorline = false,
					foldcolumn = "0",
				},
			},
			plugins = {
				gitsigns = { enabled = false },
				tmux = { enabled = true },
				twilight = { enabled = true },
			},
		},
	},

	-- ── Twilight: atenúa el texto fuera del bloque actual ───────────────
	{
		"folke/twilight.nvim",
		cmd = "Twilight",
		opts = {
			dimming = {
				alpha = 0.30,
			},
			context = 15,
			treesitter = true,
		},
	},

	-- ── Opciones específicas para Markdown ──────────────────────────────
	{
		"LazyVim/LazyVim",
		opts = function(_, opts)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "markdown.mdx" },
				callback = function()
					local o = vim.opt_local
					-- nowrap ya es global; las tablas se mantienen alineadas
					o.spell = false -- Desactivar spell (activar manualmente si se necesita)
					o.conceallevel = 2 -- Ocultar sintaxis markdown para vista limpia
					o.textwidth = 0 -- No auto-insertar saltos de línea duros
					o.formatoptions:remove("t") -- No auto-wrap al escribir
				end,
			})
		end,
	},


	-- ── Desactivar diagnósticos de markdownlint en línea ────────────────
	-- Las reglas molestas ya están desactivadas en ~/.markdownlint-cli2.yaml
	-- Pero reducimos la severidad visual para que no sean intrusivos
	{
		"mfussenegger/nvim-lint",
		optional = true,
		opts = {
			linters_by_ft = {
				markdown = { "markdownlint-cli2" },
			},
		},
	},

	-- ── Desactivar auto-formateo en Markdown ────────────────────────────
	-- Prettier elimina líneas en blanco múltiples y reformatea agresivamente.
	-- Desactivamos los formateadores para que el archivo se guarde tal cual.
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				["markdown"] = {},
				["markdown.mdx"] = {},
			},
		},
	},
}
