return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
        "jayp0521/mason-null-ls.nvim",
    },
    config = function()
        require("mason-null-ls").setup {
            ensure_installed = {
                "prettier",
                "shfmt",
                "black",
                "isort",
                "flake8",
                "mypy",
                "stylua",
                "spell",
            },
            automatic_installation = true,
        }

        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.prettier.with { filetypes = { "json", "yaml", "markdown" } },
                null_ls.builtins.formatting.shfmt.with { args = { "-i", "4" } },
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.isort,
                null_ls.builtins.formatting.flake8,
                null_ls.builtins.formatting.mypy,
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.completion.spell,
            },
        })

        vim.keymap.set("n", "<Leader>gf", vim.lsp.buf.format, {})
    end,
}
