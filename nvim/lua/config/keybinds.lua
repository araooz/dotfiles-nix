vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
--vim.keymap.set("n", "<C-e>", ":NvimTreeFindFileToggle<CR>", { desc = "Abrir/cerrar nvim-tree en el archivo actual" })
vim.keymap.set("n", "<C-e>", ":NvimTreeFocus<CR>", { desc = " nvim-tree" })

-- Cerrar pestaña actual
vim.keymap.set("n", "<leader>w", ":bdelete<CR>", { desc = "Cerrar buffer actual" })

-- CTRL + a selecciona todo   CTRL + c copia
vim.keymap.set({ "n", "v", "i" }, "<C-a>", "<Esc>ggVG", { desc = "Seleccionar todo el texto" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copiar al portapapeles del sistema" })

-- Limpiar notificaciones de Noice y Notify
vim.keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<cr>", { desc = "Descartar notificaciones" })


-- Abrir links con Ctrl + Click usando Zen Browser
vim.keymap.set("n", "<C-LeftMouse>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local line = vim.api.nvim_get_current_line()

    -- Buscamos la URL que esté bajo el cursor o cerca de él
    local url = line:match("https?://[%w%-_%.%?%+=&/%%#]+", 1)

    -- Si encontramos una URL, verificamos que el cursor esté sobre ella (opcional pero preciso)
    if url then
        vim.fn.jobstart({ "zen", url }, {
            detach = true,
            on_exit = function(_, exit_code)
                if exit_code ~= 0 then
                    vim.notify("Error: No se pudo ejecutar el comando 'zen'", vim.log.levels.ERROR)
                end
            end,
        })
    end
end, { desc = "Abrir link con Zen Browser (Ctrl+Click)" })

-- También configuramos 'gx' para que use Zen por defecto
vim.g.netrw_browsex_viewer = "zen"
