-- lua/nvim-tablecalc/utils.lua
local M = {}
local config = require('nvim-tablecalc.config')

function M.parse_table(content)
  M.rows = {}
  for line in content:gmatch("[^\r\n]+") do
    if line:find("[a-zA-Z0-9]") and line:find(config.delimiter) then
      local columns = {}
      for col in line:gmatch("[^" .. config.delimiter .. "]+") do
        table.insert(columns, col)
      end
      table.insert(M.rows, columns)
    end
  end

  -- You can now process `rows`, which is a 2D table of the parsed content
  -- Example: Print the parsed table (for testing)
  for _, row in ipairs(M.rows) do
    print(vim.inspect(row))
  end
end

function M.sum(x_coords, y_coords)
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

return M
