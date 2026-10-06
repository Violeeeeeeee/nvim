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
                    vim.g.no_plugin_maps = true
                end,
            },
        },
        config = function()
            -- Main setup for Treesitter AND its extensions
            require("nvim-treesitter").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            -- Jupyter cells / Markdown code blocks
                            ["ic"] = { query = "@code_cell.inner", desc = "in block" },
                            ["ac"] = { query = "@code_cell.outer", desc = "around block" },
                            -- Functions and classes
                            -- ["im"] = { query = "@function.inner", desc = "in function" },
                            -- ["am"] = { query = "@function.outer", desc = "around function" },
                            -- ["ic"] = { query = "@class.inner", desc = "in class" },
                            -- ["ac"] = { query = "@class.outer", desc = "around class" },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = false, -- keeps jumplist clean
                        goto_next_start = {
                            ["]c"] = { query = "@code_cell.inner", desc = "next code block" },
                            -- ["]m"] = { query = "@function.outer", desc = "next function" },
                            ["]]"] = { query = "@class.inner", desc = "next class" },
                        },
                        goto_previous_start = {
                            ["[c"] = { query = "@code_cell.inner", desc = "previous code block" },
                            -- ["[m"] = { query = "@function.outer", desc = "prev function" },
                            ["[["] = { query = "@class.inner", desc = "prev class" },
                        },
                    },
                },
            })

            require("nvim-treesitter").setup({})

            require("nvim-treesitter").install({
                    "bash", "c", "diff", "lua", "luadoc", "markdown",
                    "markdown_inline", "query", "vim", "vimdoc", "python",
                    "julia", "yaml", "html", "css", "dot", "mermaid",
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        after = "nvim-treesitter",
        config = function()
            require("treesitter-context").setup({
                enable = true,
                multiwindow = false,
                max_lines = 0,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = "outer",
                mode = "cursor",
                separator = nil,
                zindex = 20,
                on_attach = nil,
            })
        end,
    }
}
