-- lua/nvim-tablecalc/parsing.lua
local Parsing = {}
-- local utils = require('nvim-tablecalc.utils')

Parsing.__index = Parsing

-- Create a new Parsing instance
function Parsing.new(table_calc_instance)
  local self = setmetatable({}, Parsing)
  self.table_calc_instance = table_calc_instance
  self.config = self.table_calc_instance:get_config()
  self.utils = self.table_calc_instance:get_utils()
  self.rows = {}
  return self
end

-- Clears the current parsing state
function Parsing:reset()
  self.rows = {}
end

-- Parses a structured table with headers and stores it in a nested format
function Parsing:parse_structured_table(content)
  self:reset()
  local current_table_name = "" -- Variable to keep track of the current table name
  local headers = {}            -- Array to store the column headers of the current table

  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^" .. self.config.table_name_marker) then
      -- Extract the table name, the last word in a row beginning with #
      current_table_name = line:match(self.config.table_name_marker .. "%s*.-%s(%w+)%s*$")
      self.rows[current_table_name] = {} -- Initialize a table for the extracted name
      headers = {}                       -- Reset headers for the new table
    elseif line:match(self.config.delimiter) then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch(self.config.delimiter .. "%s*([^" .. self.config.delimiter .. "]+)%s*") do
          -- Extract last word to use as alias
          header = header:match("%s*(%w+)%s*$")
          table.insert(headers, self.utils.stripe(header))              -- Clean and add header
          self.rows[current_table_name][self.utils.stripe(header)] = {} -- Create sub-tables for headers
        end
      else
        -- Parse table rows and map values to their corresponding headers
        local row_index = tonumber(line:match("|%s*(%d+)")) -- Extract the row index
        local col_index = 1                                 -- Track the column index for mapping
        for value in line:gmatch("|%s*([^|]+)%s*") do
          local header = headers[col_index]
          if row_index then
            -- Map the value to the correct header and row index
            self.rows[current_table_name][header][row_index] = self.utils.stripe(value)
          end
          col_index = col_index + 1 -- Move to the next column
        end
      end
    end
  end

  -- After parsing the structured table, process the data (handle formulas, etc.)
  self.utils:process_data(self.rows) -- Process formulas and update the table data
  -- self.utils.write_to_buffer(self.rows)  -- Write the updated data back to the buffer
end

return Parsing
