-- lua/nvim-tablecalc/parsing.lua

---@class Parsing
---@field table_calc_instance TableCalc Instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field utils Utils Utility functions for parsing
---@field rows table A table storing parsed rows, structured by table names and headers
local Parsing = {}

Parsing.__index = Parsing

--- Creates a new instance of Parsing
---@param table_calc_instance TableCalc The instance of the TableCalc class
---@return Parsing A new instance of the Parsing class
function Parsing.new(table_calc_instance)
  local self = setmetatable({}, Parsing)
  -- Store the reference to the TableCalc instance
  self.table_calc_instance = table_calc_instance
  -- Get the configuration and utilities from the TableCalc instance
  self.config = self.table_calc_instance:get_config()
  self.utils = self.table_calc_instance:get_utils()
  self.rows = {} -- Initialize an empty table to store rows
  return self
end

--- Parses a structured table with headers and stores it in a nested format
---@param content string The content to be parsed, containing table data
---@return table The parsed rows stored in a nested table format
function Parsing:parse_structured_table(content)
  local current_table_name = "" -- Variable to track the current table name
  local headers = {}            -- Array to store the column headers of the current table

  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^" .. self.config.table_name_marker) then
      -- Extract the table name (last word after the `#`)
      current_table_name = line:match(self.config.table_name_marker .. "%s*.-%s(%w+)%s*$")
      self.rows[current_table_name] = {} -- Initialize a table for the extracted table name
      headers = {}                       -- Reset headers for the new table
    elseif line:match(self.config.delimiter) then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch(self.config.delimiter .. "%s*([^" .. self.config.delimiter .. "]+)%s*") do
          -- Extract and clean the header, then store it
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

  -- After parsing the structured table, return the parsed rows
  return self.rows
end

return Parsing
