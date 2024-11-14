-- lua/nvim-tablecalc/utils.lua
local M = {}
local config = require('nvim-tablecalc.config')

function M.parse_table(content)
  M.rows = {}
  for line in content:gmatch("[^\r\n]+") do
    -- to only parse lines with content
    if line:find("[a-zA-Z0-9]") and line:find(config.delimiter) then
      local columns = {}
      for col in line:gmatch("[^" .. config.delimiter .. "]+") do
        table.insert(columns, col)
      end
      table.insert(M.rows, columns)
    end
  end

  M.output_data()
end

-- Function to parse a structured table with a header
function M.parse_structured_table(content)
  M.rows = {}                   -- Define rows as a global array in M to store the final parsed data
  local current_table_name = "" -- Variable for storing the current table name
  local headers = {}            -- Array for storing the header names

  -- Split content by lines
  for line in content:gmatch("[^\r\n]+") do
    -- Check if the line starts with a table name (indicated by #)
    if line:match("^#") then
      current_table_name = line:match("#%s*(.+)") -- Extract the table name
      M.rows[current_table_name] = {}             -- Initialize a nested table for this table
      headers = {}                                -- Reset headers for a new table
    elseif line:match("|") then
      -- If headers are not set, parse the header line
      if #headers == 0 then
        for header in line:gmatch("|%s*([^|]+)%s*") do
          table.insert(headers, M.stripe(header))
          M.rows[current_table_name][M.stripe(header)] = {} -- Create sub-tables in rows
        end
      else
        -- Parse the table row and map values to corresponding headers
        local row_index = tonumber(line:match("|%s*(%d+)")) -- Extract row index
        local col_index = 1
        for value in line:gmatch("|%s*([^|]+)%s*") do
          local header = headers[col_index]
          if row_index then
            M.rows[current_table_name][header][row_index] = M.stripe(value)
          end
          col_index = col_index + 1
        end
      end
    end
  end

  -- Call output_data to handle or display rows
  -- print(vim.inspect(M.rows))
  local new_data = M.evaluate_formulas(M.rows)
  -- print(vim.inspect(new_data))
  M.write_to_buffer(new_data)
end

function M.evaluate_formulas(table_data)
  -- Loop over each row and column in the parsed table
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Check if cell contains a formula (starting with `=`)
        local formula = cell:match("^=%((.+)%)")
        if formula then
          -- Replace `ColumnName[Index]` pattern with actual values
          local eval_formula = formula:gsub("([%w_]+)%[(%d+)%]", function(col, index)
            index = tonumber(index) -- Convert index to a number
            -- Return the corresponding value if exists, otherwise "0"
            return tonumber(table_name[col] and table_name[col][index] or "0")
          end)
          -- Evaluate the mathematical expression and append result to the cell
          local result = load("return " .. eval_formula)() -- Dangerous if external input, careful!
          table_name[column][i] = cell:match("=%b()") .. ": " .. result   -- Append result to original formula
        end
      end
    end
  end
  return table_data
end

-- Function to write manipulated data back to the buffer
function M.write_to_buffer(table_data)
  -- Iterate through each table and its columns
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      -- Loop through each row to check for calculated formulas
      for row_index, cell_content in pairs(rows) do
        -- Check if cell_content contains a formula with result (e.g., "=(expression): result")
        local formula, result = cell_content:match("^(=%(.-%)): (.+)$")
        if formula and result then
          -- print(formula)
          -- print(result)
          -- Search in the buffer for the specific formula location and append result
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            -- Search for the formula pattern in the current line
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              -- Append result while keeping the original formula intact
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break -- Stop searching for this formula once replaced
            end
          end
        end
      end
    end
  end

  -- Format buffer with gggqG
  vim.cmd("normal gggqG")
end

function M.sum(x_coords, y_coords)
  if not x_coords then
    x_coords = '1-' .. #M.rows[1]
    y_coords = '1-' .. #M.rows
  end

  local x = M.parse_coordinates(x_coords)
  local y = M.parse_coordinates(y_coords)
  local total_sum = 0

  for _, col in ipairs(x) do
    for _, row in ipairs(y) do
      if tonumber(M.rows[row][col]) then
        total_sum = total_sum + tonumber(M.rows[row][col])
      end
    end
  end

  print("Total sum: " .. total_sum)
  return total_sum
end

function M.parse_coordinates(coord_str)
  local coords = {}
  if coord_str:find("-") then
    local start, finish = coord_str:match("(%d+)%-(%d+)")
    start, finish = tonumber(start), tonumber(finish)
    for num = start, finish do table.insert(coords, tonumber(num)) end
  elseif coord_str:find(",") then
    for num in string.gmatch(coord_str, '([^,]+)') do
      table.insert(coords, tonumber(num))
    end
  else
    table.insert(coords, tonumber(coord_str))
  end
  return coords
end

function M.output_data()
  -- Calculate the max width of each column
  local col_widths = {}
  for _, row in ipairs(M.rows) do
    for col_num, value in ipairs(row) do
      local value_str = tostring(value)
      col_widths[col_num] = math.max(col_widths[col_num] or 0, #value_str) -- Update column width if necessary
    end
  end

  -- Format column header
  local col_header = '    ' -- Reserve space for row numbers
  for col_num = 1, #M.rows[1] do
    -- The column header consists of the column numbers
    col_header = col_header .. string.format("%-" .. col_widths[col_num] .. "d", col_num)
  end
  print(col_header)

  -- Iterate through the rows and print them
  for row_num, row in ipairs(M.rows) do
    local row_output = row_num .. ' ' -- Print row number left-aligned
    for col_num, value in ipairs(row) do
      -- Format each column's value
      row_output = row_output .. string.format("%-" .. col_widths[col_num] .. "s", tostring(value))
    end
    print(row_output) -- Output the entire row
  end
end

function M.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

return M
