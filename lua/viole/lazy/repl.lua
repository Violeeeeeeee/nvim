return {
    {
        'benlubas/molten-nvim',
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        ft = { "python", "markdown", "quarto" },

        init = function()
            vim.g.molten_auto_open_output = false
            vim.g.molten_image_location = "float"
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_border = { "", "━", "", "" }
            vim.g.molten_output_win_max_height = 12
            vim.g.molten_virt_text_output = true
            vim.g.molten_use_border_highlights = true
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_wrap_output = true
            vim.g.molten_tick_rate = 142

            vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { desc = "[M]olten [I]nit", silent = true })
            vim.keymap.set("n", "<leader>ip", function()
                local venv = os.getenv("VIRTUAL_ENV")
                if venv ~= nil then
                -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
                    venv = string.match(venv, "/.+/(.+)")
                    vim.cmd(("MoltenInit %s"):format(venv))
                else
                    vim.cmd("MoltenInit python3")
                end
            end, { desc = "Init Molten for python3 (venv)", silent = true, noremap = true })

            vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MoltenInitPost",
                callback = function()
                    local r = require("quarto.runner")

                    -- quarto code runner mappings
                    vim.keymap.set("n", "<S-CR>", r.run_cell, { desc = "Run Cell and Step", silent = true })
                    vim.keymap.set("n", "<leader>rc", r.run_cell, { desc = "[R]un [C]ell", silent = true })
                    vim.keymap.set("n", "<leader>ra", r.run_all, { desc = "[R]un [A]ll", silent = true })
                    vim.keymap.set("n", "<leader>rA", r.run_above, { desc = "[R]un [A]bove", silent = true })
                    vim.keymap.set("n", "<leader>rb", r.run_below, { desc = "[R]un [B]elow", silent = true })
                    vim.keymap.set("n", "<leader>rl", r.run_line, { desc = "[R]un [L]ine", silent = true })

                    -- setup some molten specific keybindings
                    vim.keymap.set("n", "<leader>mr", ":MoltenEvaluateOperator<CR>", { desc = "Molten Evaluate Operator", silent = true })
                    vim.keymap.set("n", "<leader>mer", ":MoltenReevaluateCell<CR>", { desc = "[M]olten [R]eevaluate Cell", silent = true })
                    vim.keymap.set("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
                    vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
                    vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

                    -- Перемикач автоматичного відкриття вікна виводу
                    local open = false
                    vim.keymap.set("n", "<leader>ot", function()
                        open = not open
                        vim.fn.MoltenUpdateOption("auto_open_output", open)
                    end, { desc = "Toggle auto open output" })

                    -- if we're in a python file, change the configuration a little
                    if vim.bo.filetype == "python" then
                        vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
                        vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
                    end
                end,
            })

            -- change the configuration when editing a python file
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*.py",
                callback = function(e)
                    if string.match(e.file, ".otter.") then return end
                    local ok, status = pcall(require("molten.status").initialized)
                    if ok and status == "Molten" then
                        vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
                        vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
                    end
                end,
            })

            -- Undo those config changes when we go back to a markdown or quarto file
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = { "*.qmd", "*.md", "*.ipynb" },
                callback = function()
                    local ok, status = pcall(require("molten.status").initialized)
                    if ok and status == "Molten" then
                        vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", true)
                        vim.fn.MoltenUpdateOption("molten_virt_text_output", true)
                    end
                end,
            })

            local imb = function(e)
                vim.schedule(function()
                    local kernels = vim.fn.MoltenAvailableKernels()

                    local try_kernel_name = function()
                        local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
                        return metadata.kernelspec.name
                    end
                    local ok, kernel_name = pcall(try_kernel_name)

                    if not ok or not vim.tbl_contains(kernels, kernel_name) then
                        kernel_name = nil
                        local venv = os.getenv("VIRTUAL_ENV")
                        if venv ~= nil then
                            kernel_name = string.match(venv, "/.+/(.+)")
                        end
                    end

                    if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
                        vim.cmd(("MoltenInit %s"):format(kernel_name))
                    end
                    vim.cmd("MoltenImportOutput")
                end)
            end

            vim.api.nvim_create_autocmd("BufAdd", {
                pattern = { "*.ipynb" },
                callback = imb,
            })
        end,
    },
}
