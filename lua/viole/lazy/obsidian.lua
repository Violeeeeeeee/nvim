local prefix = "<leader>o"

return {
    {
        "epwalsh/obsidian.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        event = "BufReadPre " .. vim.fn.expand("~") .. "/notes/cnn-research/**.md",
        keys = {
            { prefix .. "o",       "<cmd>ObsidianOpen<cr>",            desc = "Obsidian: Open on App" },
            { prefix .. "g",       "<cmd>ObsidianSearch<cr>",          desc = "Obsidian: Grep" },
            { prefix .. "n",       "<cmd>ObsidianNew<cr>",             desc = "Obsidian: New Note" },
            { prefix .. "N",       "<cmd>ObsidianNewFromTemplate<cr>", desc = "Obsidian: New Note (Template)" },
            { prefix .. "<space>", "<cmd>ObsidianQuickSwitch<cr>",     desc = "Obsidian: Find Files" },
            { prefix .. "b",       "<cmd>ObsidianBacklinks<cr>",       desc = "Obsidian: Backlinks" },
            { prefix .. "t",       "<cmd>ObsidianTags<cr>",            desc = "Obsidian: Tags" },
            { prefix .. "T",       "<cmd>ObsidianTemplate<cr>",        desc = "Obsidian: Template" },
            {
                prefix .. "L",
                "<cmd>ObsidianLink<cr>",
                mode = "v",
                desc = "Obsidian: Link",
            },
            { prefix .. "l", "<cmd>ObsidianLinks<cr>",     desc = "Obsidian: Links" },
            {
                prefix .. "nl",
                "<cmd>ObsidianLinkNew<cr>",
                mode = "v",
                desc = "Obsidian: New Link",
            },
            {
                prefix .. "e",
                "<cmd>ObsidianExtractNote<cr>",
                mode = "v",
                desc = "Obsidian: Extract Note",
            },
            { prefix .. "w", "<cmd>ObsidianWorkspace<cr>", desc = "Obsidian: Workspace" },
            { prefix .. "r", "<cmd>ObsidianRename<cr>",    desc = "Obsidian: Rename" },
            { prefix .. "i", "<cmd>ObsidianPasteImg<cr>",  desc = "Obsidian: Paste Image" },
            { prefix .. "d", "<cmd>ObsidianDailies<cr>",   desc = "Obsidian: Daily Notes" },
        },

        config = function()
            require("obsidian").setup({
                workspaces = {
                    {
                        name = "cnn-research",
                        path = "~/notes/cnn-research",
                    },
                },

                notes_subdir = "inbox",
                new_notes_location = "notes_subdir",

                disable_frontmatter = true,

                templates = {
                    subdir = "templates",
                    date_format = "%Y-%m-%d",
                    time_format = "%H:%M",
                    substitutions = {},
                },

                -- Optional, customize how note IDs are generated given an optional title.
                ---@param title string|?
                ---@return string
                note_id_func = function(title)
                    -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                    -- In this case a note with the title 'My new note' will be given an ID that looks
                    -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                    local suffix = ""
                    if title ~= nil then
                        -- If title is given, transform it into valid file name.
                        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                    else
                        -- If title is nil, just add 4 random uppercase letters to the suffix.
                        for _ = 1, 4 do
                            suffix = suffix .. string.char(math.random(65, 90))
                        end
                    end
                    return tostring(os.date("%Y-%m-%d")) .. "-" .. suffix
                end,

                -- -- Optional, customize how note file names are generated given the ID, target directory, and title.
                -- ---@param spec { id: string, dir: obsidian.Path, title: string|? }
                -- ---@return string|obsidian.Path The full path to the new note.
                -- note_path_func = function(spec)
                -- 	-- This is equivalent to the default behavior.
                -- 	local path = spec.dir / tostring(spec.id)
                -- 	return path:with_suffix(".md")
                -- end,

                mappings = {
                    -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
                    ["gf"] = {
                        action = function()
                            return require("obsidian").util.gf_passthrough()
                        end,
                        opts = { desc = "Obsidian: link shit", noremap = false, expr = true, buffer = true },
                    },
                    -- toggle check-boxes
                    ["<leader>oct"] = {
                        action = function()
                            return require("obsidian").util.toggle_checkbox()
                        end,
                        opts = { desc = "Obsidian: Toggle checkbox", buffer = true },
                    },
                },

                completion = {
                    nvim_cmp = true,
                    min_chars = 2,
                    blink = false,
                },

                ui = { enable = false },
            })
        end,
    },
    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                { "<Leader>o", group = "obsidian", icon = " ", mode = { "n", "v" } },
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
            table.insert(opts.sections.lualine_x, 1, "g:obsidian")
        end,
    },
}
