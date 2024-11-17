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
  self.commands = require('nvim-tablecalc.commands').new()     -- Instanziiere Commands mit TableCalc-Instanz
  self.config = require('nvim-tablecalc.config').new()         -- Instanziiere Config
  self.utils = require('nvim-tablecalc.utils').new(self)
  self.parsing = require('nvim-tablecalc.parsing').new(self)   -- Instanziiere Parsing
  self.core = require('nvim-tablecalc.core').new(self)         -- Instanziiere Core
  self.setup_done = false                                      -- Flag, das anzeigt, ob setup() bereits ausgeführt wurde
  return self
end

-- Setup-Methode
function TableCalc:setup()
  if not self.setup_done then -- Prüfe, ob setup() schon ausgeführt wurde
    self.commands:setup()     -- Setzt die Keybindings
    self.setup_done = true    -- Markiere, dass setup() ausgeführt wurde
  end
end

function TableCalc:get_config()
  return self.config
end

function TableCalc:get_parsing()
  return self.parsing
end

function TableCalc:get_core()
  return self.core
end

function TableCalc:get_utils()
  return self.utils
end

return TableCalc
