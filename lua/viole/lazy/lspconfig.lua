return {
    "neovim/nvim-lspconfig",
    config = function()
        local lspconfig = require("lspconfig")
        lspconfig.clangd.setup({})
        lspconfig.pylsp.setup({})
    end,
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup({})
        end,
    }
}
