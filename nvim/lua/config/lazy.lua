local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "goolord/alpha-nvim", opts = function() return require("alpha.themes.dashboard") end },
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },

		-- UI
		{ import = "lazyvim.plugins.extras.ui.alpha" },

		-- 2. Import Language Extras (This sets up LSP, Formatting, Debugging)
		{ import = "lazyvim.plugins.extras.lang.clangd" }, -- C / C++
		{ import = "lazyvim.plugins.extras.lang.python" }, -- Python
		{ import = "lazyvim.plugins.extras.lang.rust" }, -- Rust
		{ import = "lazyvim.plugins.extras.lang.typescript" }, -- TS / JS
		{ import = "lazyvim.plugins.extras.lang.java" }, -- Java
		{ import = "lazyvim.plugins.extras.lang.markdown" }, -- Markdown
		{ import = "lazyvim.plugins.extras.lang.zig" }, -- Zig

		-- import your plugins
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	--install = { colorscheme = { " vague" } },  Luego veo si es que se puede instalar el tema asi
	checker = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
