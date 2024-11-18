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
  self.config = require('nvim-tablecalc.config').new()
  self.utils = require('nvim-tablecalc.utils').new(self)
  self.parsing = require('nvim-tablecalc.parsing').new(self)
  self.core = require('nvim-tablecalc.core').new(self)
  self.setup_done = false
  return self
end

-- Setup-Methode
function TableCalc:setup()
  if not self.setup_done then -- Prüfe, ob setup() schon ausgeführt wurde
    require('nvim-tablecalc.commands').setup()     -- Setzt die Keybindings
    self.setup_done = true    -- Markiere, dass setup() ausgeführt wurde
  end
end

function TableCalc:run_normal()
  local content = self.core:read_buffer_normal()
  local tables = self.parsing:parse_structured_table(content)
  local modified_data = self.utils:process_data(tables)
  self.core:write_to_buffer(modified_data)
end

function TableCalc:run_visual()
  local content = self.core:read_buffer_visual()
  local tables = self.parsing:parse_structured_table(content)
  local modified_data = self.utils:process_data(tables)
  self.core:write_to_buffer(modified_data)
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
