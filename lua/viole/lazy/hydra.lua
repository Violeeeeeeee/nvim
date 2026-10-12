return {
    "nvimtools/hydra.nvim",
    config = function()
        vim.api.nvim_set_hl(0, "HydraRed", { fg = "#E67E80", bold = true })
        vim.api.nvim_set_hl(0, "HydraBlue", { fg = "#7FBBB3", bold = true })
        vim.api.nvim_set_hl(0, "HydraAmaranth", { fg = "#D699B6", bold = true })
        vim.api.nvim_set_hl(0, "HydraTeal", { fg = "#83C092", bold = true })
        vim.api.nvim_set_hl(0, "HydraPink", { fg = "#D699B6", bold = true })

        vim.api.nvim_set_hl(0, "HydraHint", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "HydraBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "HydraTitle", { link = "FloatTitle" })
        vim.api.nvim_set_hl(0, "HydraFooter", { link = "FloatTitle" })

        require("hydra").setup({
            hint = {
                type = "window",
                show_name = false,
                position = { "middle" },
                border = "rounded",
            },
        })
    end,
}
