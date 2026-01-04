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

            -- Налаштування запуску (Runner)
            local runner = require("quarto.runner")

            -- === КЛАВІШІ (KEYMAPS) ===

            -- Ctrl + Enter: Запустити клітинку
            vim.keymap.set("n", "<C-CR>", runner.run_cell, { desc = "Run Cell", silent = true })
            vim.keymap.set("i", "<C-CR>", runner.run_cell, { desc = "Run Cell", silent = true })

            -- Shift + Enter: Запустити і перейти далі
            vim.keymap.set("n", "<S-CR>", function()
                runner.run_cell()
            end, { desc = "Run Cell and Step", silent = true })

            -- Leader + rc (Run Cell), Leader + ra (Run All)
            vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "[R]un [C]ell" })
            vim.keymap.set("n", "<leader>ra", runner.run_all, { desc = "[R]un [A]ll" })

            -- Leader + ip: Відкрити термінал IPython (справа)
            vim.keymap.set("n", "<leader>ip", function()
                -- Відкриваємо IPython, бо він краще працює з блоками коду ніж звичайний python
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
            -- ВАЖЛИВО: Налаштування змінних ДО завантаження плагіна (init)
            vim.g.slime_target = 'neovim'
            vim.g.slime_no_mappings = true
            vim.g.slime_python_ipython = 1 -- Вмикаємо режим IPython для коректної вставки

            -- Змінні, які раніше викликали помилку, тепер тут:
            vim.g.slime_input_pid = false
            vim.g.slime_suggest_default = true
            vim.g.slime_menu_config = false
            vim.g.slime_neovim_ignore_unlisted = true

            vim.b['quarto_is_python_chunk'] = false
            -- Функція для визначення мови поточного блоку (для otter/slime)
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
