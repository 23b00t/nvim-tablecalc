-- lua/nvim-tablecalc/core.lua
local Core = {}
Core.__index = Core

-- Create a new Core instance
function Core.new(table_calc_instance)
  local self = setmetatable({}, Core)
  self.table_calc_instacne = table_calc_instance
  self.config = table_calc_instance:get_config()
  return self
end

-- Singleton method removed. Use Core.new() directly.

-- Read the entire buffer in normal mode
function Core:read_buffer_normal()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, '\n')
end

-- Read the selected buffer in visual mode
function Core:read_buffer_visual()
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')

  if start_pos[1] > end_pos[1] then
    error("Invalid visual selection")
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  return table.concat(lines, '\n')
end

-- Writes the modified table data back to the buffer
function Core:write_to_buffer(table_data)
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      for _, cell_content in pairs(rows) do
        local formula, result = cell_content:match("^(%" ..
          self.config.formula_begin .. ".-%" .. self.config.formula_end .. "): (.+)$")
        if formula and result then
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break
            end
          end
        end
      end
    end
  end
  vim.cmd(self.config:autoformat_buffer())
end
return Core
