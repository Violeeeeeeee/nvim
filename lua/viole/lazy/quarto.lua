return {
    {
        "GCBallesteros/jupytext.nvim",
        -- ft = { "ipynb" },
        opts = {
            style = "markdown",
            output_extension = "md",
            force_ft = "markdown",
            custom_language_formatting = {
                python = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' },
            },
        },
    },
    { "jmbuhr/otter.nvim", ft = { "markdown", "quarto" } },
    {
        "quarto-dev/quarto-nvim",
        dependencies = {
            "nvim-lspconfig",
            "nvimtools/hydra.nvim",
            "jmbuhr/otter.nvim",
        },
        ft = { "quarto", "markdown" },
        config = function()
            local quarto = require("quarto")
            quarto.setup({
                lspFeatures = {
                    languages = { "python", "bash", "lua" },
                    chunks = "all", -- 'curly' or 'all'
                    diagnostics = {
                        enabled = true,
                        triggers = { "BufWritePost" },
                    },
                    completion = {
                        enabled = true,
                    },
                },
                keymap = {
                    hover = "H",
                    definition = "gd",
                    rename = "<leader>rn",
                    references = "gr",
                    format = "<leader>gf",
                },
                codeRunner = {
                    enabled = true,
                    ft_runners = {
                        bash = "slime",
                    },
                    default_method = "molten",
                },
            })

            vim.keymap.set("n", "<localleader>qp", quarto.quartoPreview,
                { desc = "Preview the Quarto document", silent = true, noremap = true })
            -- to create a cell in insert mode, I have the ` snippet
            -- vim.keymap.set("n", "<localleader>cc", "i`<c-j>", { desc = "Create a new code cell", silent = true })
            vim.keymap.set("n", "<localleader>cs", "i```\r\r```{}<left>", { desc = "Split code cell", silent = true, noremap = true })
        end,
    },

    { -- Nabla (Math)
        'jbyuki/nabla.nvim',
        keys = {
            { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'Toggle [M]ath' },
        },
    },

    { -- Image.nvim
        "3rd/image.nvim",
        opts = {
            backend = "kitty",
            max_width = 100,
            max_height = 12,
            max_width_window_percentage = math.huge,
            max_height_window_percentage = math.huge,
            window_overlap_clear_enabled = true,
        }
    },

    { -- Img-clip
        'HakonHarnes/img-clip.nvim',
        event = 'BufEnter',
        ft = { 'markdown', 'quarto', 'latex' },
        opts = {
            default = { dir_path = 'img' },
            filetypes = {
                markdown = { url_encode_path = true, template = '![$CURSOR]($FILE_PATH)', drag_and_drop = { download_images = false } },
                quarto = { url_encode_path = true, template = '![$CURSOR]($FILE_PATH)', drag_and_drop = { download_images = false } },
            },
        },
        config = function(_, opts)
            require('img-clip').setup(opts)
            vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
        end,
    },
}
