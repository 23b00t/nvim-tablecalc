-- lua/nvim-tablecalc/core.lua
local Parsing = require('nvim-tablecalc.parsing')

-- Core Module
local Core = {}
Core.__index = Core

-- Create a new Core instance
function Core.new()
  local self = setmetatable({}, Core)
  self.parsing = Parsing.new()  -- Initialize Parsing instance
  return self
end

-- Singleton method removed. Use Core.new() directly.

-- Read the entire buffer in normal mode
function Core:read_buffer_normal()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  self.parsing:parse_structured_table(content)
end

-- Read the selected buffer in visual mode
function Core:read_buffer_visual()
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')

  if start_pos[1] > end_pos[1] then
    print("Invalid visual selection")
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  local content = table.concat(lines, '\n')
  self.parsing:parse_structured_table(content)
end

return Core
