-- lua/nvim-tablecalc/config.lua

---@class Config
---@field delimiter string The character used as a delimiter in tables
---@field formula_begin string The character marking the beginning of a formula
---@field formula_end string The character marking the end of a formula
---@field table_name_marker table The character used to mark table names
---@field filetype string The current file type (default is 'org')
---@field user_command string Finishing command set by user
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
  self.table_name_marker = {
    org = '#',
    markdown = '%[%/%/%]: #',
  }
  self.user_command = nil
  self.commands = {
    org = 'normal gggqG',
    -- TODO: Add more filetypes, e.g., md, csv
  }
  return self
end

--- Gets the command associated with the current filetype
---@return string The command for the current filetype
function Config:get_command()
  if self.user_command then
    return self.user_command
  else
    return self.commands[vim.bo.filetype] or ''
  end
end

--- Returns the command to autoformat the buffer based on the current filetype
---@return string The autoformat command for the buffer
function Config:autoformat_buffer()
  return self:get_command()
end

---@return string table_name_marker
function Config:get_table_name_marker()
  return self.table_name_marker[vim.bo.filetype] or '#'
end

---@param user_config table
-- INFO: Custom config:
-- config = function()
--   require("nvim-tablecalc").get_instance():setup({ table_name_marker = '+' })
-- end,
function Config:set_user_config(user_config)
  for key, value in pairs(user_config) do
    if self[key] then
      self[key] = value
    end
  end
end

return Config
