local function keys(str)
  return function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), "m", true)
  end
end

local ok, Hydra = pcall(require, "hydra")
if ok then
Hydra({
  name = "Notebook",
  hint = "_j_/_k_: ↑/↓ | _o_/_O_: new cell ↓/↑ | _l_: run | _s_how/_h_ide | run _a_bove",
  config = {
    color = "pink",
    invoke_on_body = true,

    hint = {
        position = "bottom",
        border = "rounded",
    },
  },
  mode = { "n" },
  body = "<localleader>j",
  heads = {
    { "j", keys("]b"), { desc = "↓" } },
    { "k", keys("[b"), { desc = "↑" } },
    { "o", "o```\n\n```<esc>k", { desc = "new cell ↓", exit = true } },
    { "O", "O```\n\n```<esc>k", { desc = "new cell ↑", exit = true } },
    { "l", ":QuartoSend<CR>", { desc = "run" } },
    { "s", ":noautocmd MoltenEnterOutput<CR>", { desc = "show" } },
    { "h", ":MoltenHideOutput<CR>", { desc = "hide" } },
    { "a", ":QuartoSendAbove<CR>", { desc = "run above" } },
    { "<esc>", nil, { exit = true, desc = false } },
    { "q", nil, { exit = true, desc = false } },
  },
})
end
