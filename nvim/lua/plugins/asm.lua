return {
	-- 1. Treesitter: syntax highlighting for assembly files (.s, .S, .asm)
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "asm" },
		},
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				asm_lsp = {
					filetypes = { "asm", "s", "S" },
				},
				single_file_support = true,
			},
		},
	},
}
