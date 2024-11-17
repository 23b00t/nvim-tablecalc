-- lua/nvim-tablecalc/config.lua
local Config = {}
Config.__index = Config

-- Constructor
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

-- Get the command for the current filetype
function Config:get_command()
  return self.commands[self.filetype] or error("Invalid filetype in config")
end

return Config
