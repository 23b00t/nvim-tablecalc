-- lua/nvim-tablecalc/commands.lua
local M = {}

function M.setup()
  vim.api.nvim_set_keymap('n', '<leader>tc', ':lua require("nvim-tablecalc.core").read_buffer_normal()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<leader>tc', ':lua require("nvim-tablecalc.core").read_buffer_visual()<CR>',
    { noremap = true, silent = true })
end

return M
