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

return M
