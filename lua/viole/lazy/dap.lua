return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "jay-babu/mason-nvim-dap.nvim",
        "theHamsta/nvim-dap-virtual-text",
    },

    config = function()
        -- 	local dap = require("dap")
        -- 	local dapui = require("dapui")
        --
        -- 	vim.keymap.set("n", "<leader>dtb", dap.toggle_breakpoint, { desc = "dap: [t]oggle [b]reakpoint" })
        -- 	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "dap: [c]ontinue" })
        -- end,
        -- debugger

        local mason_dap = require("mason-nvim-dap")
        local dap = require("dap")
        local ui = require("dapui")
        local dap_virtual_text = require("nvim-dap-virtual-text")

        -- Dap Virtual Text
        dap_virtual_text.setup()

        mason_dap.setup({
            ensure_installed = { "debugpy" },
            automatic_installation = true,
            handlers = {
                function(config)
                    require("mason-nvim-dap").default_setup(config)
                end,
            },
        })

        -- Configurations
        dap.configurations = {
            python = {
                {
                    -- The first three options are required by nvim-dap
                    type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                    request = "launch",
                    name = "Launch file",

                    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                    program = "${file}", -- This configuration will launch the current file if used.
                    pythonPath = function()
                        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                        local cwd = vim.fn.getcwd()
                        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                            return cwd .. "/venv/bin/python"
                        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                            return cwd .. "/.venv/bin/python"
                        else
                            return "/usr/bin/python"
                        end
                    end,
                },
            },
        }

        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "dap: toggle [b]reakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "dap: [c]ontinue" })
        vim.keymap.set("n", "<leader>dsi", dap.step_into, { desc = "dap: [s]tep [i]nto" })
        vim.keymap.set("n", "<leader>dsv", dap.step_over, { desc = "dap: [s]tep o[v]er" })
        vim.keymap.set("n", "<leader>dso", dap.step_out, { desc = "dap: [s]tep [o]ut" })
        vim.keymap.set("n", "<leader>dsb", dap.step_back, { desc = "dap: [s]tep [b]ack" })
        vim.keymap.set("n", "<leader>dor", dap.repl.open, { desc = "dap: [o]pen [r]epl" })
        vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "dap: [r]estart" })
        vim.keymap.set("n", "<leader>?", function()
            ui.eval(nil, { enter = true })
        end, { desc = "dap: eval var under cursor" })

        -- Dap UI
        ui.setup()
        dap.listeners.before.attach.dapui_config = function()
            ui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            ui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            ui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            ui.close()
        end
    end,
}
