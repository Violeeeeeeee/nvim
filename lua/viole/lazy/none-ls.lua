return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
        "jayp0521/mason-null-ls.nvim",
    },
    config = function()
        require("mason-null-ls").setup({
            ensure_installed = {
                "prettier",
                "shfmt",
                "stylua",
                "spell",
                "black",
                "debugpy",
                "flake8",
                "isort",
                -- "mypy",
                "pylint",
            },
            automatic_installation = true,
        })
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.prettier,
                null_ls.builtins.formatting.shfmt.with({ args = { "-i", "4" } }),
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.isort,
                -- null_ls.builtins.diagnostics.mypy.with({
                -- 	ignore_missing_imports = true,
                -- }),
                require("none-ls.diagnostics.flake8").with({
                    extra_args = {
                        "--max-line-length=128",
                        "--ignore=R,duplicate-code,W0231,W0511,W1201,W1202,W0707,C0301,E203,W503,E501,C901,W293,E402,D100,no-init",
                        -- R - Refactoring-related checks: Enforces the use of snake_case naming convention.
                        -- C - Convention-related checks: Ensures adherence to established coding standards.
                        -- W0511: Disables the TODO warning.
                        -- W1201, W1202: Disables log format warnings, which may be false positives.
                        -- W0231: Disables the super-init-not-called warning as pylint may not comprehend six.with_metaclass(ABCMeta).
                        -- W0707: Disables the raise-missing-from warning, which is incompatible with Python 2 backward compatibility.
                        -- C0301: Disables the "line too long" warning, as the Black formatter automatically handles long lines.
                        -- E203:  whitespace before :
                        -- W503:  line break before binary operator
                        -- E501:  line too long
                        -- C901:  mccabe complexity
                        -- W293:  blank line contains whitespace
                        -- E402:  module import not at top (covered by pylint instead)
                        -- D100:  Missing docstring in public module
                    },
                }),
                null_ls.builtins.completion.spell,
            },
            -- you can reuse a shared lspconfig on_attach callback here
            opts = {
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                                -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
                                vim.lsp.buf.format({ bufnr })
                            end,
                        })
                    end
                end,
            },
        })
    end,
    -- vim.keymap.set("n", "<Leader>gf", vim.lsp.buf.format, {})
}
