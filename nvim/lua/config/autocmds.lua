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
