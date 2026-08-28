return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "BufLeave", "FocusLost" },
  opts = {
    enabled = true,
    execution_message = {
      enabled = false, -- Cambia a true si quieres ver un mensaje al guardar
    },
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = { "InsertLeave" }, -- Evita TextChanged para que no guarde ni ejecute el formateador LSP a cada letra que escribes
      cancel_deferred_save = { "InsertEnter" },
    },
    condition = function(buf)
      local fn = vim.fn
      -- No guardar buffers especiales (terminales, explorador, sin nombre, etc.)
      if fn.getbufvar(buf, "&buftype") ~= "" or fn.expand("%") == "" then
        return false
      end
      return true
    end,
  },
}
