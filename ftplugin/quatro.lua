-- Вказуємо vim-slime, що роздільником клітинок є потрійні лапки
-- Це дозволяє відправляти код блоками через <C-Enter>
vim.b.slime_cell_delimiter = "```"

-- Налаштування відображення тексту для Quarto (м'який перенос рядків)
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.showbreak = "| "

-- Якщо хочеш, щоб у .qmd файлах перевірка орфографії вмикалася автоматично:
-- vim.opt_local.spell = true
-- vim.opt_local.spelllang = "en,uk"
