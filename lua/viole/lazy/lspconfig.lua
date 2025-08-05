return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.clangd.setup({})
            lspconfig.pylsp.setup({})
        end
    },
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup({})
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "clangd", "pylsp" },
            })
        end,
    },
}
