return {
    { -- Quarto (LSP)
        'quarto-dev/quarto-nvim',
        dev = false,
        ft = { "quarto", "markdown" },
        dependencies = {
            'jmbuhr/otter.nvim',
            'nvim-treesitter/nvim-treesitter',
            'jpalardy/vim-slime',
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
                -- default_method = 'molten',
                default_method = 'slime',
            },
        },
        config = function(_, opts)
            require('quarto').setup(opts)
            local runner = require("quarto.runner")

            -- === 1. Helper functions ===
            local function new_terminal(lang)
                vim.cmd('vsplit term://' .. lang)
            end
            local function new_terminal_python() new_terminal 'python' end
            local function new_terminal_ipython() new_terminal 'ipython --no-confirm-exit --no-autoindent' end

            -- === 2. Slime / Tmux Runner ===
            local function run_in_pane(pane_index)
                vim.b.slime_config = { socket_name = "default", target_pane = ":." .. pane_index }
                runner.run_cell()
                vim.notify("Sent to Pane " .. pane_index, vim.log.levels.INFO)
            end

            -- === 3. Smart Send (Molten check) ===
            -- Ця функція перевіряє: якщо Molten активний -> виконуємо в ньому.
            -- Якщо ні -> виконуємо через Slime у Pane 1 (Calculations).
            local function smart_send()
                local molten = require('molten.status')
                if molten.initialized() and molten.kernels() ~= nil then
                    vim.cmd("MoltenReevaluateCell")
                else
                    run_in_pane("1") -- Default to Pane 1 (Calc) if Molten is off
                end
            end

            -- === 4. Keymaps ===
            -- Ваші поточні бінди (Slime/Tmux)
            vim.keymap.set("n", "<leader>rc", function() run_in_pane("1") end, { desc = "[R]un [C]ell in Pane 1 (Calc)", silent = true })
            vim.keymap.set("n", "<leader>rp", function() run_in_pane("2") end, { desc = "[R]un [P]lot in Pane 2 (Plots)", silent = true })
            -- Smart Execute (Ctrl+Enter)
            vim.keymap.set("n", "<C-CR>", smart_send, { desc = "Run Cell (Smart)", silent = true })
            vim.keymap.set("i", "<C-CR>", smart_send, { desc = "Run Cell (Smart)", silent = true })
            -- Molten Specific Actions (поки ви розбираєтесь)
            vim.keymap.set("n", "<leader>mi", ":MoltenInit<cr>", { desc = "[M]olten [I]nit" })
            vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<cr>", { desc = "[M]olten [R]un Cell" })
            vim.keymap.set("n", "<leader>md", ":MoltenDelete<cr>", { desc = "[M]olten [D]elete Cell" })
            vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<cr>", { desc = "[M]olten [H]ide Output" })
            -- Інше
            vim.keymap.set("n", "<S-CR>", runner.run_cell, { desc = "Run Cell and Step", silent = true })
            vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "[R]un [A]ll" })
            vim.keymap.set("n", "<leader>qp", require('quarto').quartoPreview, { desc = "[Q]uarto [P]review" })
            -- Quick Terminals
            vim.keymap.set("n", "<leader>ci", new_terminal_ipython, { desc = "New [I]Python Term" })
            vim.keymap.set("n", "<leader>cp", new_terminal_python, { desc = "New [P]ython Term" })
            -- Otter (LSP) features
            vim.keymap.set("n", "<leader>os", function()
                -- Показати символи (функції/класи) поточної мови чанка
                local lang = require('otter.keeper').get_current_language_context()
                if lang then
                    -- Тут можна викликати Telescope або нативний lsp
                    vim.lsp.buf.document_symbol()
                end
            end, { desc = "[O]tter [S]ymbols"})
        end
    },

    { -- Jupytext
        'GCBallesteros/jupytext.nvim',
        opts = {
            custom_language_formatting = {
                python = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' },
            },
        },
    },

    { -- Vim-slime (Tmux configuration)
        'jpalardy/vim-slime',
        dev = false,
        init = function()
            vim.g.slime_target = 'tmux'
            vim.g.slime_bracketed_paste = 1
            vim.g.slime_default_config = { socket_name = "default", target_pane = ":.2" }
            vim.g.slime_dont_ask_default = 1
            vim.g.slime_python_ipython = 1

            -- Fix indentation for IPython
            vim.b['quarto_is_python_chunk'] = false
            Quarto_is_in_python_chunk = function()
                require('otter.tools.functions').is_otter_language_context 'python'
            end

            vim.cmd [[
            let g:slime_dispatch_ipython_pause = 100
            function SlimeOverride_EscapeText_quarto(text)
                call v:lua.Quarto_is_in_python_chunk()
                if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
                    return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
                else
                    return [a:text]
                end
            endfunction
            ]]
        end,
    },

    { -- Nabla (Math)
        'jbyuki/nabla.nvim',
        keys = {
            { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'Toggle [M]ath' },
        },
    },

    { -- Molten (Jupyter Kernels inside Neovim)
        'benlubas/molten-nvim',
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        init = function()
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_auto_open_output = false -- Не відкривати автоматично, щоб не заважало
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
        end,
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
