-- Вказуємо vim-slime, що роздільником клітинок є `# %%`
-- Це дозволяє запускати .py файли частинами, як ноутбуки
vim.b.slime_cell_delimiter = "#\\s\\=%%"

-- Налаштування відступів (згідно PEP8, хоча treesitter це теж робить)
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

-- Автоматично згортати довгі рядки (якщо треба)
-- vim.opt_local.wrap = true
