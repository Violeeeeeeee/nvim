return {
    "nvimtools/hydra.nvim",
    dependencies = {
        "quarto-dev/quarto-nvim",
        "benlubas/molten-nvim",
    },
    config = function()
        local Hydra = require("hydra")
        local runner = require("quarto.runner")

        Hydra({
            name = "Notebook Mode",
            hint = [[
 _j_/_k_: next/prev cell      _r_: run cell           _R_: run above
 _l_: run line                _x_: hide output        _X_: clear output
 ^ ^                          _i_: initialize molten  _<Esc>_/_q_: exit
            ]],
            config = {
                invoke_on_body = true,
                hint = {
                    position = "bottom",
                    border = "rounded",
                },
            },
            mode = "n",
            -- Entry point for the Hydra mode. Change "<localleader>n" to your preferred keymap.
            body = "<localleader>n",
            heads = {
                { "j", "]b", { desc = "next cell" } },
                { "k", "[b", { desc = "previous cell" } },
                -- Code execution via Quarto runner
                { "r", runner.run_cell, { desc = "run cell" } },
                { "R", runner.run_above, { desc = "run cell and above" } },
                { "l", runner.run_line, { desc = "run line" } },

                -- Molten output management
                { "x", ":MoltenHideOutput<CR>", { desc = "hide output" } },
                { "X", ":MoltenDelete<CR>", { desc = "delete cell output" } },
                { "i", ":MoltenInit<CR>", { exit = true, desc = "initialize Molten" } },

                -- Exit Hydra mode
                { "q", nil, { exit = true, nowait = true, desc = "exit" } },
                { "<Esc>", nil, { exit = true, nowait = true, desc = "exit" } },
            }
        })
    end
}
