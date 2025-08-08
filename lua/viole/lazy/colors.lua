--function ColorMyPencils(color)
--	color = color or "rose-pine-dawn"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end
--
--return {
--    {
--        "rose-pine/neovim",
--        name = "rose-pine",
--        config = function()
--            require('rose-pine').setup({
--                disable_background = true,
--                styles = {
--                    italic = false,
--                },
--            })
--
--            ColorMyPencils();
--        end
--    },
--
--
--}

local M = {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
}

function M.config()
    local everforest = require("everforest")
    everforest.setup({
        background = "medium",
        transparent_background_level = 0,
        italics = false,
        disable_italic_comments = true,
        inlay_hints_background = "dimmed",
        on_highlights = function(hl, _)
            hl["@string.special.symbol.ruby"] = { link = "@field" }
        end,
    })
    everforest.load()
end

return M
