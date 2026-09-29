-- LazyVim: respetar siempre el directorio actual (no auto-detectar raíz del proyecto)
vim.g.root_spec = { "cwd" }

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.relativenumber = false

--identacion
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.autoindent = false
vim.opt.smartindent = false

-- Scroll horizontal suave (no wrap) — las tablas y líneas largas no se quiebran
vim.opt.wrap = false          -- Desactivar wrap: las líneas largas se extienden fuera de la pantalla
vim.opt.sidescroll = 1        -- Scroll horizontal suave (1 columna a la vez, no saltos bruscos)
vim.opt.sidescrolloff = 8     -- Mantener 8 columnas de contexto al hacer scroll horizontal
