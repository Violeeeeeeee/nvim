return {
    {
        -- Quarto (LSP & Native Code Runner)
        'quarto-dev/quarto-nvim',
        dev = false,
        ft = { "quarto", "markdown" },
        dependencies = {
            'jmbuhr/otter.nvim',
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            lspFeatures = {
                enabled = true,
                chunks = 'curly',
                languages = { "python", "bash", "lua" },
                diagnostics = {
                    enabled = true,
                    triggers = { "BufWritePost" },
                },
                completion = {
                    enabled = true,
                },
            },
            codeRunner = {
                enabled = true,
                -- Force Quarto to use Molten exclusively for code execution
                default_method = 'molten',
            },
        },
        config = function(_, opts)
            require('quarto').setup(opts)
            local runner = require("quarto.runner")

            -- 1. Execution Keymaps (Jupyter-style)
            -- Directly execute the chunk under the cursor using Quarto's parser
            vim.keymap.set("n", "<C-CR>", runner.run_cell, { desc = "Run Cell (Molten)", silent = true })
            vim.keymap.set("i", "<C-CR>", runner.run_cell, { desc = "Run Cell (Molten)", silent = true })
            vim.keymap.set("n", "<S-CR>", runner.run_above, { desc = "Run Cells Above", silent = true })
            vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "[R]un [A]ll Cells", silent = true })

            -- 2. Molten Specific Commands
            -- Initialize the kernel (e.g., your 'mlops' kernel)
            vim.keymap.set("n", "<leader>mi", ":MoltenInit<cr>", { desc = "[M]olten [I]nit" })
            -- Evaluate only the visually selected lines instead of the whole chunk
            vim.keymap.set("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "[M]olten [R]un Visual" })
            -- Manage output windows
            vim.keymap.set("n", "<leader>md", ":MoltenDelete<cr>", { desc = "[M]olten [D]elete Output" })
            vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<cr>", { desc = "[M]olten [H]ide Output" })
            vim.keymap.set("n", "<leader>ms", ":MoltenShowOutput<cr>", { desc = "[M]olten [S]how Output" })

            -- 3. Otter (LSP) Features
            -- Fetch symbols (functions, classes) from the injected language context
            vim.keymap.set("n", "<leader>os", function()
                local lang = require('otter.keeper').get_current_language_context()
                if lang then
                    vim.lsp.buf.document_symbol()
                end
            end, { desc = "[O]tter [S]ymbols"})
        end
    },

    {
        -- Molten (Jupyter Kernels inside Neovim)
        'benlubas/molten-nvim',
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        init = function()
            -- Connect Molten to the image.nvim provider for inline plots
            vim.g.molten_image_provider = "image.nvim"

            -- Keep output tucked away in virtual text until explicitly requested
            vim.g.molten_auto_open_output = false
            vim.g.molten_wrap_output = true

            -- Show output inline as virtual text below the cell
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
        end,
    },

    {
        -- Image.nvim (Renders matplotlib/seaborn plots directly in Neovim)
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
}
