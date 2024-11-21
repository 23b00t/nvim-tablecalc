-- lua/nvim-tablecalc/core.lua

---@class Core
---@field table_calc_instance TableCalc Instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field utils Utils
local Core = {}
Core.__index = Core

--- Creates a new instance of Core
---@param table_calc_instance TableCalc The instance of the TableCalc class
---@return Core A new instance of the Core class
function Core.new(table_calc_instance)
  local self = setmetatable({}, Core)
  -- Store the reference to the TableCalc instance
  self.table_calc_instance = table_calc_instance
  -- Get the configuration from the TableCalc instance
  self.config = table_calc_instance:get_config()
  self.utils = table_calc_instance:get_utils()
  return self
end

--- Reads the entire buffer in normal mode
---@return string The content of the buffer in normal mode
function Core:read_buffer_normal()
  -- Get all lines from the buffer and concatenate them into a single string
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  self.buffer = table.concat(lines, '\n')

  return self.buffer
end

--- Reads the selected buffer in visual mode
---@return string The content of the selected lines in visual mode
---@throws error If the visual selection is invalid
function Core:read_buffer_visual()
  -- Get the start and end positions of the visual selection
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')

  if start_pos[1] > end_pos[1] then
    error("Invalid visual selection")
  end

  -- Get the lines within the visual selection and concatenate them into a string
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  self.buffer = table.concat(lines, '\n')

  return self.buffer
end

--- Writes the modified table data back to the buffer
---@param table_data table The modified table data to be written back to the buffer
function Core:write_to_buffer(table_data)
  -- Iterate through each column, row, and cell content in the table data
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      for _, cell_content in pairs(rows) do
        -- Match the formula and result from the cell content
        local formula, result = cell_content:match("^(%" ..
          self.config.formula_begin .. ".-%" .. self.config.formula_end .. "): (.+)$")
        if formula and result then
          local escaped_formula = vim.pesc(formula)
          self.buffer = self.buffer:gsub(
            escaped_formula .. ":?%s*[%d%.]*",
            escaped_formula .. ': ' .. result
          )
        end
      end
    end
  end
  -- Split self.buffer into lines
  local lines = vim.split(self.buffer, '\n', { plain = true })
  -- Replace the entire buffer content with the new lines
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  -- Run autoformat command after writing to the buffer
  vim.cmd(self.config:autoformat_buffer())
end

return Core
