-- lua/nvim-tablecalc/parsing.lua
local Parsing = {}
local config = require('nvim-tablecalc.config').new()  -- Erstelle eine Instanz von Config
local utils = require('nvim-tablecalc.utils')

Parsing.__index = Parsing
local instance = nil

-- Singleton-Methode: Gibt immer dieselbe Instanz zurück
function Parsing.get_instance()
  if not instance then
    instance = Parsing.new()
  end
  return instance
end

-- Konstruktor
function Parsing.new()
  local self = setmetatable({}, Parsing)
  self.rows = {}  -- Initialisiere die Zeilen für jede Instanz
  return self
end

-- Parses a structured table with headers and stores it in a nested format
function Parsing:parse_structured_table(content)
  local current_table_name = ""  -- Variable to keep track of the current table name
  local headers = {}             -- Array to store the column headers of the current table

  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^" .. config.table_name_marker) then
      -- Extract the table name, the last word in a row beginning with #
      current_table_name = line:match(config.table_name_marker .. "%s*.-%s(%w+)%s*$")
      self.rows[current_table_name] = {}  -- Initialize a table for the extracted name
      headers = {}                         -- Reset headers for the new table
    elseif line:match(config.delimiter) then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch(config.delimiter .. "%s*([^" .. config.delimiter .. "]+)%s*") do
          -- Extract last word to use as alias
          header = header:match("%s*(%w+)%s*$")
          table.insert(headers, utils.stripe(header))           -- Clean and add header
          self.rows[current_table_name][utils.stripe(header)] = {} -- Create sub-tables for headers
        end
      else
        -- Parse table rows and map values to their corresponding headers
        local row_index = tonumber(line:match("|%s*(%d+)"))  -- Extract the row index
        local col_index = 1  -- Track the column index for mapping
        for value in line:gmatch("|%s*([^|]+)%s*") do
          local header = headers[col_index]
          if row_index then
            -- Map the value to the correct header and row index
            self.rows[current_table_name][header][row_index] = utils.stripe(value)
          end
          col_index = col_index + 1  -- Move to the next column
        end
      end
    end
  end

  -- After parsing the structured table, process the data (handle formulas, etc.)
  utils.process_data(self.rows)  -- Process formulas and update the table data
  utils.write_to_buffer(self.rows)  -- Write the updated data back to the buffer
end

return Parsing
