return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jayp0521/mason-null-ls.nvim",
	},
	config = function()
		require("mason-null-ls").setup({
			ensure_installed = {
				"prettier",
				"shfmt",
				"stylua",
				"spell",
			},
			automatic_installation = true,
		})
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.prettier.with({ filetypes = { "json", "yaml", "markdown" } }),
				null_ls.builtins.formatting.shfmt.with({ args = { "-i", "4" } }),
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.completion.spell,
			},
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
							-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
							vim.lsp.buf.format({ async = false })
						end,
					})
				end
			end,
		})

		-- vim.keymap.set("n", "<Leader>gf", vim.lsp.buf.format, {})
	end,
}
