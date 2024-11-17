-- lua/nvim-tablecalc/commands.lua
local Commands = {}
Commands.__index = Commands

-- Konstruktor
function Commands.new()
  local self = setmetatable({}, Commands)
  return self
end

-- Setup-Methode
function Commands:setup()
  -- Mapping für Normalmodus
  vim.api.nvim_set_keymap('n', '<leader>tc',
    ':lua require("nvim-tablecalc.commands").run_read_buffer_normal()<CR>',
    { noremap = true, silent = true })

  -- Mapping für Visualmodus
  vim.api.nvim_set_keymap('v', '<leader>tc',
    ':lua require("nvim-tablecalc.commands").run_read_buffer_visual()<CR>',
    { noremap = true, silent = true })
end

-- Führt die read_buffer_normal Methode aus
function Commands.run_read_buffer_normal()
  local core_instance = require('nvim-tablecalc.core').new() -- Neue Instanz erstellen
  core_instance:read_buffer_normal()                         -- Methode aufrufen
end

-- Führt die read_buffer_visual Methode aus
function Commands.run_read_buffer_visual()
  local core_instance = require('nvim-tablecalc.core').new() -- Neue Instanz erstellen
  core_instance:read_buffer_visual()                         -- Methode aufrufen
end

return Commands
