return {
    "epwalsh/obsidian.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("obsidian").setup({
            workspaces = {
                {
                    name = "cn-research",
                    path = "~/notes/cnn-research",
                },
            },

            disable_frontmatter = true,
            templates = {
                subdir = "templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M:%S",
            },

            mappings = {
                -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
                ["gf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
                ["<Leader>onn"] = {
                    action = "<cmd>ObsidianNew<cr>",
                    opts = { desc = "new note" },
                },
                ["<Leader>ont"] = {
                    action = "<cmd>ObsidianNewFromTemplate<cr>",
                    opts = { desc = "new note from template" },
                },
                -- toggle check-boxes
                ["<leader>ti"] = {
                    action = function()
                        return require("obsidian").util.toggle_checkbox()
                    end,
                    opts = { buffer = true },
                },
            },
            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },
            -- Optional, configure additional syntax highlighting / extmarks.
            -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
            ui = {
                enable = false, -- set to false to disable all additional syntax features
                update_debounce = 200, -- update delay after a text change (in milliseconds)
                max_file_length = 5000, -- disable UI features for files with more than this many lines
                -- Define how various check-boxes are displayed
                checkboxes = {
                    -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                    [" "] = { char = "󰄱", hl_group = "ObsidianTodo", order = 1 },
                    ["x"] = { char = "", hl_group = "ObsidianDone", order = 2 },
                    [">"] = { char = "", hl_group = "ObsidianRightArrow", order = 3 },
                    ["~"] = { char = "󰰱", hl_group = "ObsidianTilde", order = 4 },
                    ["!"] = { char = "", hl_group = "ObsidianImportant", order = 5 },
                    -- Replace the above with this if you don't have a patched font:
                    -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                    -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

                    -- You can also add more custom ones...
                },
                -- Use bullet marks for non-checkbox lists.
                bullets = { char = "•", hl_group = "ObsidianBullet" },
                external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                -- Replace the above with this if you don't have a patched font:
                -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                reference_text = { hl_group = "ObsidianRefText" },
                highlight_text = { hl_group = "ObsidianHighlightText" },
                tags = { hl_group = "ObsidianTag" },
                block_ids = { hl_group = "ObsidianBlockID" },
                hl_groups = {
                    -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
                    ObsidianTodo = { bold = true, fg = "#f78c6c" },
                    ObsidianDone = { bold = true, fg = "#89ddff" },
                    ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                    ObsidianTilde = { bold = true, fg = "#ff5370" },
                    ObsidianImportant = { bold = true, fg = "#d73128" },
                    ObsidianBullet = { bold = true, fg = "#89ddff" },
                    ObsidianRefText = { underline = true, fg = "#c792ea" },
                    ObsidianExtLinkIcon = { fg = "#c792ea" },
                    ObsidianTag = { italic = true, fg = "#89ddff" },
                    ObsidianBlockID = { italic = true, fg = "#89ddff" },
                    ObsidianHighlightText = { bg = "#75662e" },
                },
            },
        })
    end,
}
