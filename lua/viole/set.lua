-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true
-- Don't show the mode, since it's already in the status line
--vim.o.showmode = false
-- Enable break indent
vim.o.breakindent = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 1000

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- see `:help 'confirm'`
vim.o.confirm = true

-- [[ basic keymaps ]]
--  see `:help vim.keymap.set()`

-- Tabs
vim.opt.tabstop = 4        -- Number of spaces that a <Tab> character displays as
vim.opt.softtabstop = 4    -- Number of spaces inserted when pressing <Tab>
vim.opt.shiftwidth = 4     -- Number of spaces used for autoindent (>> or <<)
vim.opt.expandtab = true   -- Convert tabs to spaces

vim.opt.wrap = false             -- Disable line wrapping

vim.opt.swapfile = false         -- Don't use swap files
vim.opt.backup = false           -- Don't create backup files
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"  -- Set undo history directory
vim.opt.undofile = true          -- Enable persistent undo (across sessions)

vim.opt.hlsearch = false         -- Don't highlight all search matches
vim.opt.incsearch = true -- Show matches while typing the search
