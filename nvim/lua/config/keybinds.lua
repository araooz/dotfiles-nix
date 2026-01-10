vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
--vim.keymap.set("n", "<C-e>", ":NvimTreeFindFileToggle<CR>", { desc = "Abrir/cerrar nvim-tree en el archivo actual" })
vim.keymap.set("n", "<C-e>", ":NvimTreeFocus<CR>", { desc = " nvim-tree" })

-- Cerrar pestaña actual
vim.keymap.set("n", "<leader>w", ":bdelete<CR>", { desc = "Cerrar buffer actual" })

-- CTRL + a selecciona todo   CTRL + c copia
vim.keymap.set({ "n", "v", "i" }, "<C-a>", "<Esc>ggVG", { desc = "Seleccionar todo el texto" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copiar al portapapeles del sistema" })

vim.keymap.set("v", "<S-dc>", '"+y', { desc = "Copiar al portapapeles del sistema" })



vim.keymap.set("n", "<S-Up>", "Vk", {})
vim.keymap.set("n", "<S-Down>", "Vj", {})
vim.keymap.set("n", "<S-Left>", "vh", {})
vim.keymap.set("n", "<S-Right>", "vl", {})

