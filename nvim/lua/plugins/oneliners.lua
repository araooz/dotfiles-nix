return {
    {    --This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    }, { --Git plugin
    'tpope/vim-fugitive',
}, {     --Show CSS Colors
    'brenoprata10/nvim-highlight-colors',
    config = function()
        require('nvim-highlight-colors').setup({})
    end
},


    -- Source - https://stackoverflow.com/a/79656109
    -- Posted by Jo Totland
    -- Retrieved 2026-05-21, License - CC BY-SA 4.0
    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim", "hl" } }
            }
        }
    })


}
