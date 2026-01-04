return {
    { -- Плагін для Quarto (LSP, виконання коду)
        'quarto-dev/quarto-nvim',
        dev = false,
        ft = { "quarto", "markdown" },
        dependencies = {
            'jmbuhr/otter.nvim',           -- Магія для LSP всередині markdown
            'nvim-treesitter/nvim-treesitter',
            'jpalardy/vim-slime',          -- Відправка коду в термінал
        },
        opts = {
            lspFeatures = {
                enabled = true,
                chunks = 'curly', -- підтримка блоків коду ```python
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
                default_method = 'slime',
            },
        },
        config = function(_, opts)
            require('quarto').setup(opts)

            local runner = require("quarto.runner")

            vim.keymap.set("n", "<C-CR>", runner.run_cell, { desc = "Run Cell", silent = true })
            vim.keymap.set("i", "<C-CR>", runner.run_cell, { desc = "Run Cell", silent = true })
            vim.keymap.set("n", "<S-CR>", function()
                runner.run_cell()
            end, { desc = "Run Cell and Step", silent = true })
            vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "[R]un [C]ell" })
            vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "[R]un [A]ll" })
            vim.keymap.set("n", "<leader>ip", function()
                vim.cmd("vsplit term://ipython --no-confirm-exit")
                vim.cmd("wincmd p") -- повернутися назад у код
            end, { desc = "[I]nit [P]ython Terminal" })
            -- Leader + qp: Відкрити прев'ю документа (в браузері)
            vim.keymap.set("n", "<leader>qp", require('quarto').quartoPreview, { desc = "[Q]uarto [P]review" })
        end
    },

    { -- Jupytext: дозволяє відкривати .ipynb як текстові файли markdown
        'GCBallesteros/jupytext.nvim',
        opts = {
            custom_language_formatting = {
                python = {
                    extension = 'qmd',
                    style = 'quarto',
                    force_ft = 'quarto',
                },
            },
        },
    },

    { -- Vim-slime: механізм відправки тексту в термінал
        'jpalardy/vim-slime',
        dev = false,
        init = function()
            vim.g.slime_target = 'neovim'
            vim.g.slime_no_mappings = true
            vim.g.slime_python_ipython = 1
            vim.g.slime_input_pid = false
            vim.g.slime_suggest_default = true
            vim.g.slime_menu_config = false
            vim.g.slime_neovim_ignore_unlisted = true
            vim.b['quarto_is_python_chunk'] = false
            Quarto_is_in_python_chunk = function()
                require('otter.tools.functions').is_otter_language_context 'python'
            end

            -- Хак для коректної вставки коду в IPython (через %cpaste)
            vim.cmd [[
            let g:slime_dispatch_ipython_pause = 100
            function SlimeOverride_EscapeText_quarto(text)
                call v:lua.Quarto_is_in_python_chunk()
                if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
                    return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
                else
                    return [a:text]
                end
            endfunction
            ]]
        end,
        config = function()
            -- Тільки налаштування клавіш для налаштування самого терміналу
            local function mark_terminal()
                local job_id = vim.b.terminal_job_id
                vim.print('job_id: ' .. job_id)
            end
            local function set_terminal()
                vim.fn.call('slime#config', {})
            end
            vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
            vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
        end,
    },
    { -- Nabla (LaTeX формули)
        'jbyuki/nabla.nvim',
        keys = {
            { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'Toggle [M]ath' },
        },
    },

    { -- Molten (Jupyter Kernels + Images)
        'benlubas/molten-nvim',
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "3rd/image.nvim", -- Для картинок
        },
        init = function()
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_auto_open_output = false -- Краще відкривати вручну, щоб не заважало
            vim.g.molten_output_win_max_height = 20
        end,
        keys = {
            { "<leader>mi", ":MoltenInit<cr>", desc = "[M]olten [I]nit" },
            { "<leader>me", ":MoltenEvaluateOperator<cr>", desc = "[M]olten [E]valuate" },
            { "<leader>rr", ":MoltenEvaluateLine<cr>", desc = "[R]un Line (Molten)" },
            { "<leader>rc", ":MoltenReevaluateCell<cr>", desc = "[R]e-run [C]ell (Molten)" },
            { "<leader>md", ":MoltenDelete<cr>", desc = "[M]olten [D]elete cell" },
            { "<leader>mh", ":MoltenHideOutput<cr>", desc = "[M]olten [H]ide" },
            { "<leader>mo", ":noautocmd MoltenEnterOutput<cr>", desc = "[M]olten [O]utput Enter" },
        },
    },

    { -- Image.nvim (потрібен для Molten)
        "3rd/image.nvim",
        opts = {
            backend = "kitty", -- Або "ueberzug" якщо термінал не підтримує kitty protocol
            max_width = 100,
            max_height = 12,
            max_width_window_percentage = math.huge,
            max_height_window_percentage = math.huge,
            window_overlap_clear_enabled = true,
        }
    },
    { -- Вставка картинок з буфера обміну
        'HakonHarnes/img-clip.nvim',
        event = 'BufEnter',
        ft = { 'markdown', 'quarto', 'latex' },
        opts = {
            default = {
                dir_path = 'img',
            },
            filetypes = {
                markdown = {
                    url_encode_path = true,
                    template = '![$CURSOR]($FILE_PATH)',
                    drag_and_drop = { download_images = false },
                },
                quarto = {
                    url_encode_path = true,
                    template = '![$CURSOR]($FILE_PATH)',
                    drag_and_drop = { download_images = false },
                },
            },
        },
        config = function(_, opts)
            require('img-clip').setup(opts)
            vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
        end,
    },
}
