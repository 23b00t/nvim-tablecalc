-- lua/nvim-tablecalc/commands.lua
local Commands = {}
Commands.__index = Commands

-- Constructor
function Commands.new()
  local self = setmetatable({}, Commands)
  return self
end

-- Setup method
function Commands:setup()
  vim.api.nvim_set_keymap('n', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance().core:read_buffer_normal()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance().core:read_buffer_visual()<CR>',
    { noremap = true, silent = true })
end

return Commands
