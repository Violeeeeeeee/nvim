local function keys(str)
  return function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), "m", true)
  end
end

local ok, Hydra = pcall(require, "hydra")
if ok then
Hydra({
  name = "Notebook",
  hint = "_j_/_k_: ↑/↓ | _o_/_O_: new cell ↓/↑ | _S_: split cell | _l_: run | _s_/_h_: show/hide",
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
    -- { "o", "o```{python}\n\n```<esc>k", { desc = "new cell ↓", exit = true } },
    -- { "O", "O```{python}\n\n```<esc>k", { desc = "new cell ↑", exit = true } },
    { "o", keys("/^```<CR>:nohl<CR>o<CR>```{python}<CR><CR>```<esc>k"), { desc = "new cell ↓", exit = true } },
    { "O", keys("?^```<CR>:nohl<CR>O```{python}<CR><CR>```<CR><esc>kk"), { desc = "new cell ↑", exit = true } },
    { "S", keys("o```<CR><CR>```{python}<esc>k"), { desc = "split cell", exit = true } },
    { "l", ":QuartoSend<CR>", { desc = "run" } },
    { "s", ":noautocmd MoltenEnterOutput<CR>", { desc = "show" } },
    { "h", ":MoltenHideOutput<CR>", { desc = "hide" } },
    { "a", ":QuartoSendAbove<CR>", { desc = "run above" } },
    { "<esc>", nil, { exit = true, desc = false } },
    { "q", nil, { exit = true, desc = false } },
  },
})
end
