-- lua/nvim-tablecalc/core.lua

---@class Core
---@field table_calc_instance TableCalc Instance of the TableCalc class
---@field config Config Configuration object for TableCalc
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
  return self
end

--- Reads the entire buffer in normal mode
---@return string The content of the buffer in normal mode
function Core:read_buffer_normal()
  -- Get all lines from the buffer and concatenate them into a single string
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, '\n')
end

--- Reads the selected buffer in visual mode
---@return string The content of the selected lines in visual mode
---@throws error If the visual selection is invalid
function Core:read_buffer_visual()
  -- Get the start and end positions of the visual selection
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')
print(vim.inspect(end_pos))
  if start_pos[1] > end_pos[1] then
    error("Invalid visual selection")
  end

  -- Get the lines within the visual selection and concatenate them into a string
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)

  return table.concat(lines, '\n')
end

--- Writes the modified table data back to the buffer
---@param table_data any The modified table data to be written back to the buffer
function Core:write_to_buffer(table_data)
  -- Iterate through each column, row, and cell content in the table data
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      for _, cell_content in pairs(rows) do
        -- Match the formula and result from the cell content
        local formula, result = cell_content:match("^(%" ..
        self.config.formula_begin .. ".-%" .. self.config.formula_end .. "): (.+)$")
        if formula and result then
          -- Iterate through all lines in the buffer to find and update the matching line
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              -- Update the line with the new result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break
            end
          end
        end
      end
    end
  end
  -- Run autoformat command after writing to the buffer
  vim.cmd(self.config:autoformat_buffer())
end

return Core
