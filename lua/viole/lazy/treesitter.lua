return {
    {
        "nvim-treesitter/nvim-treesitter",
        dev = false,
        branch = "main",
        build = ":TSUpdate",

        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",

                init = function()
                    -- Disable entire built-in ftplugin mappings to avoid conflicts.
                    -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
                    vim.g.no_plugin_maps = true

                    -- Or, disable per filetype (add as you like)
                    -- vim.g.no_python_maps = true
                    -- vim.g.no_ruby_maps = true
                    -- vim.g.no_rust_maps = true
                    -- vim.g.no_go_maps = true
                end,
                config = function()
                    require("nvim-treesitter-textobjects").setup {
                        select = {
                            -- Automatically jump forward to textobj, similar to targets.vim
                            lookahead = true,
                        },
                    }

                    -- select
                    vim.keymap.set({ "x", "o" }, "am", function()
                        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
                    end)
                    vim.keymap.set({ "x", "o" }, "im", function()
                        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
                    end)
                    vim.keymap.set({ "x", "o" }, "ac", function()
                        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
                    end)
                    vim.keymap.set({ "x", "o" }, "ic", function()
                        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
                    end)
                    -- You can also use captures from other query groups like `locals.scm`
                    vim.keymap.set({ "x", "o" }, "as", function()
                        require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
                    end)

                    -- move
                    vim.keymap.set({ "n", "x", "o" }, "]b", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start("@code_cell.inner", "textobjects")
                    end, { desc = "next code block" })

                    vim.keymap.set({ "n", "x", "o" }, "[b", function()
                        require("nvim-treesitter-textobjects.move").goto_previous_start("@code_cell.inner", "textobjects")
                    end, { desc = "previous code block" })

                    vim.keymap.set({ "n", "x", "o" }, "]m", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
                    end)
                    vim.keymap.set({ "n", "x", "o" }, "]]", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start("@class.inner", "textobjects")
                    end)
                    -- You can also pass a list to group multiple queries.
                    vim.keymap.set({ "n", "x", "o" }, "]o", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
                    end)
                    -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
                    vim.keymap.set({ "n", "x", "o" }, "]s", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
                    end)
                    vim.keymap.set({ "n", "x", "o" }, "]z", function()
                        require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
                    end)

                    vim.keymap.set({ "n", "x", "o" }, "]M", function()
                        require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
                    end)
                    vim.keymap.set({ "n", "x", "o" }, "][", function()
                        require("nvim-treesitter-textobjects.move").goto_next_end("@class.inner", "textobjects")
                    end)

                    vim.keymap.set({ "n", "x", "o" }, "[m", function()
                        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
                    end)
                    vim.keymap.set({ "n", "x", "o" }, "[[", function()
                        require("nvim-treesitter-textobjects.move").goto_previous_start("@class.inner", "textobjects")
                    end)

                    vim.keymap.set({ "n", "x", "o" }, "[M", function()
                        require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
                    end)
                    vim.keymap.set({ "n", "x", "o" }, "[]", function()
                        require("nvim-treesitter-textobjects.move").goto_previous_end("@class.inner", "textobjects")
                    end)
                end,
            },
        },
        config = function()

            require("nvim-treesitter").install({
                "bash",
                "c",
                "diff",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
                "python",
                "julia",
                "yaml",
                "latex", -- requires tree-sitter-cli (installed automatically via mason)
                "html",
                "css",
                "dot",
                "mermaid",
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        after = "nvim-treesitter",
        config = function()
            require("treesitter-context").setup({
                enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false, -- Enable multiwindow support.
                max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: "inner", "outer"
                mode = "cursor", -- Line used to calculate context. Choices: "cursor", "topline"
                -- Separator between context and content. Should be a single character string, like "-".
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20, -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            })
        end,
    },
}
