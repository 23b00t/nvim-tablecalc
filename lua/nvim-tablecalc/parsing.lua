local M = {}
local config = require('nvim-tablecalc.config')
local utils = require('nvim-tablecalc.utils')

-- Parses a structured table with headers and stores it in a nested format
function M.parse_structured_table(content)
  M.rows = {}                   -- Global array to store all parsed tables
  local current_table_name = "" -- Variable to keep track of the current table name
  local headers = {}            -- Array to store the column headers of the current table

  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^#") then
      -- Extract the table name, the last word in a row beginning with #
      current_table_name = line:match("#%s*.-%s(%w+)%s*$")
      M.rows[current_table_name] = {} -- Initialize a table for the extracted name
      headers = {}                    -- Reset headers for the new table
    elseif line:match(config.delimiter) then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch(config.delimiter .. "%s*([^" .. config.delimiter .. "]+)%s*") do
          -- Extract last word to use as alias
          header = header:match("%s*(%w+)%s*$")
          table.insert(headers, utils.stripe(header))           -- Clean and add header
          M.rows[current_table_name][utils.stripe(header)] = {} -- Create sub-tables for headers
        end
      else
        -- Parse table rows and map values to their corresponding headers
        local row_index = tonumber(line:match("|%s*(%d+)")) -- Extract the row index
        local col_index = 1                                 -- Track the column index for mapping
        for value in line:gmatch("|%s*([^|]+)%s*") do
          local header = headers[col_index]
          if row_index then
            -- Map the value to the correct header and row index
            M.rows[current_table_name][header][row_index] = utils.stripe(value)
          end
          col_index = col_index + 1 -- Move to the next column
        end
      end
    end
  end

  -- Process formulas and update table data
  -- print(vim.inspect(M.rows))
  local new_data = utils.extract_formulas(M.rows)
  utils.write_to_buffer(new_data) -- Write the updated data back to the buffer
end

return M
