return {

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim",    opts = {} },
        },
        config = function()
            local on_attach = function(_, bufnr)
                -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end

                map("K", vim.lsp.buf.hover, "Hover")
                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                map("<Leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<Leader>gca", vim.lsp.buf.code_action, "[G]oto [C]ode [A]ction", { "n", "x" })

                -- Find references for the word under your cursor.
                map("<Leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("<Leader>gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map("<Leader>gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("<Leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<Leader>gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                map("<Leader>gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map("<Leader>gtd", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype [D]efinition")
            end

            local capabilities = nil
            if pcall(require, "cmp_nvim_lsp") then
                capabilities = require("cmp_nvim_lsp").default_capabilities()
            end
            --            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local servers = {
                -- clangd = {},

                --                pyright = {
                --                    settings = {
                --                        pyright = {
                --                            -- Using Ruff's import organizer
                --                            disableOrganizeImports = true,
                --                        },
                --                        python = {
                --                            analysis = {
                --                                -- Ignore all files for analysis to exclusively use Ruff for linting
                --                                ignore = { "*" },
                --                            },
                --                        },
                --                    },
                --                },

                lua_ls = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                    -- cmd = { ... },
                    -- filetypes = { ... },
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            -- diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
            }

            require("lspconfig").pylsp.setup({
                cmd = { "pylsp" },
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    pylsp = {
                        plugins = {
                            pyflakes = { enabled = false },
                            pycodestyle = { enabled = false },
                            autopep8 = { enabled = false },
                            yapf = { enabled = false },
                            pylsp_mypy = { enabled = false },
                            pylsp_black = { enabled = false },
                            pylsp_isort = { enabled = false },
                            mccabe = { enabled = false },
                            pydocstyle = { enabled = false },
                            flake8 = { enabled = false },
                            pylint = { enabled = false },
                        },
                    },
                },
            })
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "prettier",
                "shfmt",
                "stylua",
            })

            -- Ensure the servers and tools above are installed
            -- To check the current status of installed tools and/or manually install
            -- other tools, you can run
            --    :Mason
            -- You can press `g?` for help in this menu.
            -- `mason` had to be setup earlier: to configure its options see the
            -- `dependencies` table for `nvim-lspconfig` above.
            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for ts_ls)
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },
}
