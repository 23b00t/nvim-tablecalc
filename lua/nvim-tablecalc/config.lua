-- lua/nvim-tablecalc/config.lua

---@class Config
---@field delimiter string The character used as a delimiter in tables
---@field formula_begin string The character marking the beginning of a formula
---@field formula_end string The character marking the end of a formula
---@field table_name_marker string The character used to mark table names
---@field filetype string The current file type (default is 'org')
---@field commands table A table mapping file types to commands
local Config = {}
Config.__index = Config

--- Constructor for Config class
-- Initializes the configuration with default values.
---@return Config A new instance of the Config class
function Config.new()
  local self = setmetatable({}, Config)
  self.delimiter = '|'
  self.formula_begin = '{'
  self.formula_end = '}'
  self.table_name_marker = '#'
  self.filetype = 'org'
  self.commands = {
    org = 'normal gggqG',
    -- TODO: Add more filetypes, e.g., md, csv
  }
  return self
end

--- Gets the command associated with the current filetype
---@return string The command for the current filetype
---@throws Error if the filetype is not valid in the config
function Config:get_command()
  return self.commands[self.filetype] or error("Invalid filetype in config")
end

--- Returns the command to autoformat the buffer based on the current filetype
---@return string The autoformat command for the buffer
function Config:autoformat_buffer()
  return self:get_command()
end

return Config
