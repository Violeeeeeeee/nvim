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
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<leader>gca", vim.lsp.buf.code_action, "[G]oto [C]ode [A]ction", { "n", "x" })

                -- Find references for the word under your cursor.
                map("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("<leader>gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map("<leader>gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<leader>gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                map("<leader>gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map("<leader>gtd", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype [D]efinition")
            end

            local capabilities = nil
            if pcall(require, "cmp_nvim_lsp") then
                capabilities = require("cmp_nvim_lsp").default_capabilities()
            end
            --            local capabilities = require('cmp_nvim_lsp').default_capabilities()


            local lsp = require("lspconfig")
            lsp.clangd.setup({})
            lsp.lua_ls.setup({
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
            })
            lsp.ruff.setup({
                init_options = {
                    settings = {
                        configurationPreference = "filesystemFirst",

                        lineLength = 120,  -- Line length to pass to ruff checking and formatting
                        exclude = { "__about__.py", ".venv" },  -- Files to be excluded by ruff checking
                        ignore = { "D210" },  -- Rules to be ignored by ruff
                        perFileIgnores = { ["__init__.py"] = "CPY001" },  -- Rules that should be ignored for specific files
                        organizeImports = true,
                        showSyntaxErrors = true,
                        lint = {
                            enable = true,
                            select = { "F" },  -- Rules to be enabled by ruff
                            unfixable = {"F401"},
                            extendSelect = {"TID251"},
                        },
                        format = {
                            backend = "internal",
                        }
                    }

                },
            })

            -- lsp.pyright.setup({
            --     settings = {
            --         pyright = {
            --             -- Using other import organizer
            --             disableOrganizeImports = true,
            --         },
            --         python = {
            --             analysis = {
            --                 -- Ignore all files for analysis to exclusively use other instruments for linting
            --                 ignore = { "*" },
            --             },
            --         },
            --     },
            -- })
            require("lspconfig").pylsp.setup({
                -- cmd = { "pylsp" },
                -- logs for debugging
                cmd = {"pylsp", "-vvv", "--log-file", "/tmp/lsp.log"},
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    pylsp = {
                        plugins = {
                            -- Disabling all formatting and linting tools
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

                            -- Keep navigation-related plugins enabled
                            rope_completion = { enabled = true },
                            jedi_completion = { enabled = true },
                            jedi_definition = { enabled = true },
                            jedi_hover = { enabled = true },
                            jedi_references = { enabled = true },
                            jedi_signature_help = { enabled = true },
                            jedi_symbols = { enabled = true },

                            -- -- linting/formatting via ruff
                            -- pylsp_ruff = {
                            --     enabled = true,
                            --     configurationPreference = "editorFirst",
                            --     formatEnabled = true,  -- Enable formatting using ruffs formatter
                            --     -- executable = "<path-to-ruff-bin>",  -- Custom path to ruff
                            --     -- config = "<path_to_custom_ruff_toml>",  -- Custom config for ruff to use
                            --     extendSelect = { "I" },  -- Rules that are additionally used by ruff
                            --     extendIgnore = { "C90" },  -- Rules that are additionally ignored by ruff
                            --     format = { "I" },  -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
                            --     severities = { ["D212"] = "I" },  -- Optional table of rules where a custom severity is desired
                            --     unsafeFixes = false,  -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action
                            --     unfixable = { "F401" }, -- Rules that are excluded when checking the code actions (including the "Fix All" action)
                            --
                            --     -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
                            --     lineLength = 120,  -- Line length to pass to ruff checking and formatting
                            --     exclude = { "__about__.py" },  -- Files to be excluded by ruff checking
                            --     select = { "F" },  -- Rules to be enabled by ruff
                            --     ignore = { "D210" },  -- Rules to be ignored by ruff
                            --     perFileIgnores = { ["__init__.py"] = "CPY001" },  -- Rules that should be ignored for specific files
                            --     preview = false,  -- Whether to enable the preview style linting and formatting.
                            --     targetVersion = "py310",  -- The minimum python version to target (applies for both linting and formatting).
                            -- },
                        },
                    },
                },
            })
            --
            local ensure_installed = vim.tbl_keys({})
            vim.list_extend(ensure_installed, {
                "prettier",
                "shfmt",
                "stylua",
                "debugpy",
                -- "isort",
                -- "black",
                -- "mypy",
                -- "flake8",
                -- "pylint",
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
                ensure_installed = {
                    "clangd",
                    "lua_ls",
                    "pylsp",
                    "ruff",
                    -- "pyright",
                },
            })
        end,
    },
}
