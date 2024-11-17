-- lua/nvim-tablecalc/init.lua
local TableCalc = {}
TableCalc.__index = TableCalc
local instance = nil

-- Singleton-Methode: Gibt immer dieselbe Instanz zurück
function TableCalc.get_instance()
  if not instance then
    instance = TableCalc.new()
  end
  return instance
end

-- Konstruktor
function TableCalc.new()
  local self = setmetatable({}, TableCalc)
  self.commands = require('nvim-tablecalc.commands').new()  -- Instanziiere Commands
  self.config = require('nvim-tablecalc.config').new()      -- Instanziiere Config
  self.core = require('nvim-tablecalc.core').new()          -- Instanziiere Core
  self.parsing = require('nvim-tablecalc.parsing').new()    -- Instanziiere Parsing
  return self
end

-- Setup-Methode
function TableCalc:setup()
  self.commands:setup()  -- Setzt die Keybindings
end

return TableCalc
