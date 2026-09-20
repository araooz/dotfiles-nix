-- Abrir imágenes con imv en lugar de mostrar basura binaria
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Abrir imágenes con imv",
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.webp", "*.svg", "*.ico", "*.tiff" },
  callback = function(ev)
    local filepath = vim.fn.expand("%:p")
    vim.fn.jobstart({ "imv", filepath }, { detach = true })
    -- Cerrar el buffer sin guardar (la imagen no se debería editar en nvim)
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_delete(ev.buf, { force = true })
      end
    end, 50)
  end,
})

-- Auto-guardar automáticamente al salir de Insert o perder el foco
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
  desc = "Auto-save al perder foco o salir de Insert",
  nested = true,
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})
