-- lua/nvim-tablecalc/core.lua

---@class Core
---@field table_calc_instance TableCalc Instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field utils Utils
---@field parsing Parsing
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
  self.parsing = table_calc_instance:get_parsing()
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

--- Writes the modified table data back to the buffer
---@param result_table table The modified table data to be written back to the buffer
function Core:write_to_buffer(result_table)
  for _, cell in pairs(result_table) do
    -- Match the formula and result from the cell content
    local formula, result = cell:match("^(%" ..
      self.config.formula_begin .. ".-%" .. self.config.formula_end .. "): (.+)$")
    if formula and result then
      local escaped_formula = vim.pesc(formula)
      self.buffer = self.buffer:gsub(
        escaped_formula .. ":?%s*-?[%d%.]*",
        escaped_formula .. ': ' .. result
      )
    end
  end
  -- Split self.buffer into lines
  local lines = vim.split(self.buffer, '\n', { plain = true })
  -- Replace the entire buffer content with the new lines
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  -- Run autoformat command after writing to the buffer
  ---@diagnostic disable-next-line: redundant-parameter
  vim.cmd(self.config:get_command())
end

-- Function to insert a table with rows, columns, and optional headers
---@param rows string
---@param cols string
---@param headers string
-- INFO: Example usage
-- insert_table(3, 5) -- Table with 3 columns, 5 rows, no headers
-- insert_table(3, 3, Name, Age,City) -- Table with headers
function Core:insert_table(cols, rows, headers)
  local tbl = {}

  local headers_table = self.parsing:parse_headers(headers)
  -- Check if headers are provided
  local use_headers = type(headers_table) == "table" and #headers > 0

  -- Create the header row (always empty if no headers are provided)
  local header = { "#" } -- Placeholder for the numbered column
  for c = 1, cols do
    table.insert(header, use_headers and (headers_table[c] or "") or " ")
  end

  table.insert(tbl, "| " .. table.concat(header, " | ") .. " |")
  table.insert(tbl, "|" .. string.rep("-----|", cols + 1)) -- Separator row

  -- Create data rows
  for r = 1, rows do
    local row = { tostring(r) } -- Numbered first column
    for _ = 1, cols do
      table.insert(row, " ")    -- Empty cells
    end
    table.insert(tbl, "| " .. table.concat(row, " | ") .. " |")
  end

  -- Insert the table into the current buffer
  vim.api.nvim_put(tbl, "l", true, true)

  -- Run autoformat command after writing to the buffer
  ---@diagnostic disable-next-line: redundant-parameter
  vim.cmd(self.config:get_command())
end

-- Highlight formula
function Core:highlight_curly_braces()
  self.match_id = nil
  -- Define the highlighting group
  vim.api.nvim_set_hl(0, "PurpleCurly", { fg = "#b279d2" })

  -- Add the match for formula markers and their contents, not match pipe to avoid matching the closing tag of the next cell
  self.match_id = vim.fn.matchadd("PurpleCurly", self.config.formula_begin .. "[^|]*" .. self.config.formula_end)
end

-- Remove the custom highlighting
function Core:remove_highlight()
  if self:match_exists() then vim.fn.matchdelete(self.match_id) end
end

-- Check if a formula expression was matched by vim
function Core:match_exists()
  local matches = vim.fn.getmatches() -- Get all active matches
  for _, match in ipairs(matches) do
    if match.id == self.match_id then
      return true
    end
  end
  return false
end

return Core
