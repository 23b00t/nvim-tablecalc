-- lua/nvim-tablecalc/init.lua

---@class TableCalc
---@field config Config Configuration object
---@field utils Utils Utility functions
---@field parsing Parsing Parsing functions
---@field core Core Core functionality
---@field setup_done boolean Flag to indicate if setup is complete
local TableCalc = {}
TableCalc.__index = TableCalc
local instance = nil

--- Singleton method to get the instance of TableCalc
---@return TableCalc The singleton instance of TableCalc
function TableCalc.get_instance()
  if not instance then
    instance = TableCalc.new()
  end
  return instance
end

--- Constructor to create a new TableCalc object
---@return TableCalc A new instance of TableCalc
function TableCalc.new()
  local self = setmetatable({}, TableCalc)
  -- Initialize the required components for TableCalc
  self.config = require('nvim-tablecalc.config').new()
  self.utils = require('nvim-tablecalc.utils').new(self)
  self.parsing = require('nvim-tablecalc.parsing').new(self)
  self.core = require('nvim-tablecalc.core').new(self)
  self.setup_done = false
  return self
end

--- Setup method to initialize commands for TableCalc
function TableCalc:setup()
  if not self.setup_done then
    -- Set up commands for the TableCalc
    require('nvim-tablecalc.commands').setup()
    self.setup_done = true
  end
end

--- Method to run TableCalc in normal mode
function TableCalc:run_normal()
  -- Read the buffer content in normal mode
  local content = self.core:read_buffer_normal()
  -- Parse the structured table from the content
  local tables = self.parsing:parse_structured_table(content)
  -- Process the parsed data
  local modified_data = self.utils:process_data(tables)
  -- Write the processed data back to the buffer
  self.core:write_to_buffer(modified_data)
end

--- Method to run TableCalc in visual mode
function TableCalc:run_visual()
  -- Read the buffer content in visual mode
  local content = self.core:read_buffer_visual()
  -- Parse the structured table from the content
  local tables = self.parsing:parse_structured_table(content)
  -- Process the parsed data
  local modified_data = self.utils:process_data(tables)
  -- Write the processed data back to the buffer
  self.core:write_to_buffer(modified_data)
end

--- Method to get the configuration object
---@return Config The configuration object
function TableCalc:get_config()
  return self.config
end

--- Method to get the parsing object
---@return Parsing The parsing object
function TableCalc:get_parsing()
  return self.parsing
end

--- Method to get the core functionality object
---@return Core The core object
function TableCalc:get_core()
  return self.core
end

--- Method to get the utility functions object
---@return Utils The utilities object
function TableCalc:get_utils()
  return self.utils
end

return TableCalc
