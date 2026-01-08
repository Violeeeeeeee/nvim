return {
    {
        'jmbuhr/otter.nvim',
        dev = false,
        dependencies = {
            {
                'neovim/nvim-lspconfig',
                'nvim-treesitter/nvim-treesitter',
            },
        },
        ---@type OtterConfig
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            "mason-org/mason-lspconfig.nvim",

            {
                'mason-org/mason-lspconfig.nvim',
                opts = {
                    automatic_enable = false,
                    ensure_installed = {
                        'lua_ls',
                        'bashls',
                        'cssls',
                        'html',
                        'ruff',
                        'pylsp',
                        'texlab',
                        'dotls',
                        'yamlls',
                        'clangd',
                    },
                },
            },
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            {
                'WhoIsSethDaniel/mason-tool-installer.nvim',
                opts = {
                    ensure_installed = {
                        "shfmt",
                        "stylua",
                        -- "debugpy",
                        -- "isort",
                        -- "black",
                        -- "mypy",
                        -- "flake8",
                        -- "pylint",
                        'tree-sitter-cli',
                        'jupytext',
                    },
                },
            },
            { "j-hui/fidget.nvim", opts = {} },
            "saghen/blink.cmp",
        },
        config = function()
            local util = require 'lspconfig.util'

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    assert(client, 'LSP client not found')

                    ---@diagnostic disable-next-line: inject-field
                    client.server_capabilities.document_formatting = true

                    map("K", vim.lsp.buf.hover, "Hover")
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("<leader>gca", vim.lsp.buf.code_action, "[G]oto [C]ode [A]ction", { "n", "x" })
                    map("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                    map("<leader>gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                    -- map("<leader>gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                    map("<leader>gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

                    -- map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    map("<leader>gD", vim.lsp.buf.type_definition, "[G]oto [D]eclaration")
                    map("<leader>gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
                    map("<leader>gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
                    map("<leader>gtd", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype [D]efinition")
                end,
            })

            local lsp_flags = {
                allow_incremental_sync = true,
                debounce_text_changes = 150,
            }

            local capabilities
            local has_blink, blink = pcall(require, 'blink')
            if has_blink then
                capabilities = blink.get_lsp_capabilities({}, true)
            else
                capabilities = vim.lsp.protocol.make_client_capabilities()
            end

            -- set defaults for all clients
            vim.lsp.config('*', {
                capabilities = capabilities,
                flags = lsp_flags,
                root_markers = { '.git/' },
            })

            -- also needs:
            -- $home/.config/marksman/config.toml :
            -- [core]
            -- markdown.file_extensions = ["md", "markdown", "qmd"]
            -- vim.lsp.config.marksman = {
            --   filetypes = { 'markdown', 'quarto' },
            --   root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
            -- }

            vim.lsp.config.yamlls = {
                settings = {
                    yaml = {
                        schemaStore = {
                            enable = true,
                            url = '',
                        },
                    },
                },
            }

            local function get_quarto_resource_path()
                local function strsplit(s, delimiter)
                    local result = {}
                    for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
                        table.insert(result, match)
                    end
                    return result
                end

                local f = assert(io.popen('quarto --paths', 'r'))
                local s = assert(f:read '*a')
                f:close()
                return strsplit(s, '\n')[2]
            end

            local lua_library_files = vim.api.nvim_get_runtime_file('', true)
            local lua_plugin_paths = {}
            local resource_path = get_quarto_resource_path()
            if resource_path == nil then
                vim.notify_once 'quarto not found, lua library files not loaded'
            else
                table.insert(lua_library_files, resource_path .. '/lua-types')
                table.insert(lua_plugin_paths, resource_path .. '/lua-plugin/plugin.lua')
            end

            vim.lsp.config.clangd = {}
            vim.lsp.config.lua_ls = {
                settings = {
                    Lua = {
                        completion = { callSnippet = "Replace" },
                        diagnostics = { globals = { "vim" } },
                    },
                },
            }

            vim.lsp.config.ruff = {
                init_options = {
                    settings = {
                        configurationPreference = "filesystemFirst",
                        lineLength = 120,  -- Line length to pass to ruff checking and formatting exclude = { "__about__.py", ".venv" },  -- Files to be excluded by ruff checking ignore = { "D210" },  -- Rules to be ignored by ruff
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
                        },
                    },
                },
            }

            vim.lsp.bashls = {
                filetypes = { 'sh', 'bash' },
            }

            -- See https://github.com/neovim/neovim/issues/23291
            -- disable lsp watcher.
            -- Too lags on linux for python projects
            -- because pyright and nvim both create too many watchers otherwise
            -- if capabilities.workspace == nil then
            --     capabilities.workspace = {}
            --     capabilities.workspace.didChangeWatchedFiles = {}
            -- end
            -- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

            vim.lsp.config.pyright = {
                -- capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = 'workspace',
                        },
                    },
                },
                root_markers = { '.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt' },
            }

            -- vim.lsp.config.pyright = {
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
            -- }

            -- vim.lsp.config.ltex = {
            --     settings = {
            --         ltex = {
            --             language = 'en-US',
            --             markdown = {
            --                 nodes = {
            --                     CodeBlock = "ignore",
            --                     FencedCodeBlock = "ignore",
            --                 },
            --             },
            --             additionalRules = {
            --                 enablePickyRules = false,
            --                 motherTongue = 'de-DE',
            --             },
            --             disabledRules = {
            --                 ['en-US'] = { 'FILE_EXTENSIONS_CASE', 'COMMA_PARENTHESIS_WHITESPACE', 'MORFOLOGIK_RULE_EN_US', 'WHITESPACE_RULE', 'UPPERCASE_SENTENCE_START' },
            --             }
            --         },
            --     },
            -- }

            vim.lsp.config.pylsp = {
                -- cmd = { "pylsp" },
                -- logs for debugging
                cmd = {"pylsp", "-vvv", "--log-file", "/tmp/lsp.log"},
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
            }

            -- enable the servers
            vim.lsp.enable 'cssls'
            vim.lsp.enable 'html'
            vim.lsp.enable 'jsonls'
            vim.lsp.enable 'texlab'
            vim.lsp.enable 'yamlls'
            vim.lsp.enable 'clangd'
            -- vim.lsp.enable 'ltex'
            -- vim.lsp.enable 'marksman'
            -- vim.lsp.enable 'julia-lsp'
            vim.lsp.enable 'lua_ls'
            vim.lsp.enable 'bashls'
            vim.lsp.enable 'pyright'
            vim.lsp.enable 'ruff'
            -- vim.lsp.enable 'pylsp'

        end,
    }
}
