return {
    "okuuva/auto-save.nvim",
    opts = {
        enabled = true,

        debounce_delay = 500, -- espera medio segundo desde el último cambio

        trigger_events = {
            immediate_save = { "BufLeave", "FocusLost" },
            defer_save = { "InsertLeave", "TextChanged" },
            cancel_deferred_save = { "InsertEnter" },
        },
    },
}
