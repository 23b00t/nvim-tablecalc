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
  -- Beziehe die Singleton-Instanz von TableCalc
  local table_calc_instance = require('nvim-tablecalc').get_instance()
  -- Zugriff auf die Core-Instanz
  local core_instance = table_calc_instance.core

  -- Aufruf der gewünschten Methode
  core_instance:read_buffer_normal()
end

-- Führt die read_buffer_visual Methode aus
function Commands.run_read_buffer_visual()
  -- Beziehe die Singleton-Instanz von TableCalc
  local table_calc_instance = require('nvim-tablecalc').get_instance()
  -- Zugriff auf die Core-Instanz
  local core_instance = table_calc_instance.core

  core_instance:read_buffer_visual()                         -- Methode aufrufen
end

return Commands
