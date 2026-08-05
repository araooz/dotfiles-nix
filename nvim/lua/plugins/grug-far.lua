return {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",



    vim.keymap.set("n", "<leader>h", "<cmd>GrugFar<CR>", {
        desc = "Search & Replace"
    })
}
