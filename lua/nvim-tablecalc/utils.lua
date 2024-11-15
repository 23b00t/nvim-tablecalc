-- lua/nvim-tablecalc/utils.lua
local M = {}
local config = require('nvim-tablecalc.config')

-- Parses table data from a given string content
function M.parse_table(content)
  M.rows = {} -- Initialize global rows table to store parsed rows
  for line in content:gmatch("[^\r\n]+") do
    -- Only parse lines that contain actual content and the delimiter
    if line:find("[a-zA-Z0-9]") and line:find(config.delimiter) then
      local columns = {}
      -- Split the line into columns using the delimiter
      for col in line:gmatch("[^" .. config.delimiter .. "]+") do
        table.insert(columns, col)
      end
      table.insert(M.rows, columns) -- Add the parsed columns to the rows table
    end
  end
  M.output_data() -- Output the parsed rows (if necessary)
end

-- Parses a structured table with headers and stores it in a nested format
function M.parse_structured_table(content)
  M.rows = {} -- Global array to store all parsed tables
  local current_table_name = "" -- Variable to keep track of the current table name
  local headers = {} -- Array to store the column headers of the current table

  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^#") then
      current_table_name = line:match("#%s*(.+)") -- Extract the table name
      M.rows[current_table_name] = {} -- Initialize a table for the extracted name
      headers = {} -- Reset headers for the new table
    elseif line:match(config.delimiter) then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch("|%s*([^|]+)%s*") do
          table.insert(headers, M.stripe(header)) -- Clean and add header
          M.rows[current_table_name][M.stripe(header)] = {} -- Create sub-tables for headers
        end
      else
        -- Parse table rows and map values to their corresponding headers
        local row_index = tonumber(line:match("|%s*(%d+)")) -- Extract the row index
        local col_index = 1 -- Track the column index for mapping
        for value in line:gmatch("|%s*([^|]+)%s*") do
          local header = headers[col_index]
          if row_index then
            -- Map the value to the correct header and row index
            M.rows[current_table_name][header][row_index] = M.stripe(value)
          end
          col_index = col_index + 1 -- Move to the next column
        end
      end
    end
  end

  -- Process formulas and update table data
  local new_data = M.extract_formulas(M.rows)
  M.write_to_buffer(new_data) -- Write the updated data back to the buffer
end

-- Extracts and evaluates formulas from a table and appends the result
function M.extract_formulas(table_data)
  -- Iterate through all tables and their columns
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula (starts with `=`)
        local formula = cell:match("^=%((.+)%)")
        if formula then
          -- Evaluate the formula and append the result to the cell
          local result = M.evaluate_formula(formula)
          table_name[column][i] = cell:match("=%b()") .. ": " .. result
        end
      end
    end
  end
  return table_data -- Return the updated table data
end

-- Evaluates a mathematical formula
function M.evaluate_formula(formula)
  -- Resolve references in the formula to their actual values
  local expression = M.resolve_expression(formula)
  -- Execute the mathematical expression and return the result
  local func = load("return " .. expression)
  if func then
    return func()
  end
end

-- Resolves references in a formula to their corresponding values
function M.resolve_expression(expression)
  -- Replace references of the form Table[Column[Row]] with actual values
  return expression:gsub("(%w+)%[(%a+)%[(%d+)%]%]", function(table_name, col_name, index)
    local table_data = M.rows[table_name] -- Get the table data by name
    if table_data and table_data[col_name] then
      local col_index = tonumber(index)
      return table_data[col_name][col_index] -- Return the value at the specified index
    else
      error("Invalid reference: " .. table_name .. "[" .. col_name .. "[" .. index .. "]]")
    end
  end)
end

-- Writes the modified table data back to the buffer
function M.write_to_buffer(table_data)
  -- Iterate over all tables and their columns
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      -- Process each cell to append results to formulas
      for _, cell_content in pairs(rows) do
        local formula, result = cell_content:match("^(=%(.-%)): (.+)$")
        if formula and result then
          -- Search the buffer for the formula and append the result
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              -- Update the line by appending the result to the formula
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break
            end
          end
        end
      end
    end
  end

  -- Format the buffer (e.g., re-align text)
  vim.cmd("normal gggqG")
end

-- Utility function to trim whitespace from strings
function M.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

return M
