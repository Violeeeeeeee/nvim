return {
    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config({
        severity_sort = true,
        float = {
            header = "Diagnostics",
            source = true,
            border = "rounded",
        },
        signs = vim.g.have_nerd_font and {
            text = {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = "󰋽 ",
                [vim.diagnostic.severity.HINT] = "󰌶 ",
            },
        } or {},
        virtual_text = {
            source = true,
            spacing = 2,
            format = function(diagnostic)
                -- local diagnostic_message = {
                --     [vim.diagnostic.severity.ERROR] = string.format(
                --         "%s %s",
                --         diagnostic.user_data.code,
                --         diagnostic.message
                --     ),
                --     [vim.diagnostic.severity.WARN] = string.format(
                --         "%s %s",
                --         diagnostic.user_data.code,
                --         diagnostic.message
                --     ),
                --     [vim.diagnostic.severity.INFO] = string.format(
                --         "%s %s",
                --         diagnostic.user_data.code,
                --         diagnostic.message
                --     ),
                --     [vim.diagnostic.severity.HINT] = string.format(
                --         "%s %s",
                --         diagnostic.user_data.code,
                --         diagnostic.message
                --     ),
                -- }
                -- if diagnostic.user_data and diagnostic.user_data.code then
                --     return diagnostic_message[diagnostic.severity]
                -- else
                --     return diagnostic.message
                -- end
                if diagnostic.user_data and diagnostic.user_data.code then
                    return string.format("%s %s", diagnostic.user_data.code, diagnostic.message)
                else
                    return diagnostic.message
                end
            end,
        },
    }),
}
