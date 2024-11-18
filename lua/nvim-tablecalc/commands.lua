-- lua/nvim-tablecalc/commands.lua
local Commands = {}
Commands.__index = Commands

-- Konstruktor
function Commands.new()
  local self = setmetatable({}, Commands)
  return self
end

-- Setup-Methode
function Commands.setup()
  -- Mapping für Normalmodus
  vim.api.nvim_set_keymap('n', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance():run_normal()<CR>',
    { noremap = true, silent = true })

  -- Mapping für Visualmodus
  vim.api.nvim_set_keymap('v', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance():run_visual()<CR>',
    { noremap = true, silent = true })
end

return Commands
