-- lua/nvim-tablecalc/init.lua

local M = {}
local config = require('nvim-tablecalc.config') -- Load configuration

-- Function to read the current buffer
function M.read_buffer_normal()
  -- Get the entire buffer content as a string
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n') -- Join lines to a single string

  -- Call a function to parse the table (assuming you have a parser)
  M.parse_table(content)
end

-- Function to read the current buffer
function M.read_buffer_visual()
  -- Get the start and end positions of the visual selection
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')

  -- Ensure that the start and end positions are valid
  if start_pos[1] > end_pos[1] then
    print("Invalid visual selection")
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  local content = table.concat(lines, '\n') -- Join lines to a single string

  -- Call a function to parse the table (assuming you have a parser)
  M.parse_table(content)
end

-- Function to parse the table from the buffer content
function M.parse_table(content)
  -- Example: Split the content by lines and then by the delimiter (e.g., '|')
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

-- Function to sum specific columns and rows
function M.sum(x_coords, y_coords)
  -- Parse the coordinates into arrays
  local x = M.parse_coordinates(x_coords)
  local y = M.parse_coordinates(y_coords)

  -- Initialize sum variable
  local total_sum = 0

  -- Iterate over the x coordinates (rows)
  for _, col in ipairs(x) do
    -- Iterate over the y coordinates (columns)
    for _, row in ipairs(y) do
      -- Ensure the row and column are within bounds
      if tonumber(M.rows[row][col]) then
        total_sum = total_sum + tonumber(M.rows[row][col]) -- Add value to sum
      end
    end
  end

  -- Output the total sum
  print("Total sum: " .. total_sum)
  return total_sum
end

-- Function to parse the coordinate ranges (e.g., "1-3" or "2,4")
function M.parse_coordinates(coord_str)
  local coords = {}

  -- If the part contains a range (e.g., "2-5")
  if coord_str:find("-") then
    local start, finish = coord_str:match("(%d+)%-(%d+)")
    start, finish = tonumber(start), tonumber(finish)

    -- Add all numbers in the range to the coords array
    for num = start, finish do
      table.insert(coords, tonumber(num))
    end
  elseif coord_str:find(",") then
    for num in string.gmatch(coord_str, '([^,]+)') do
      table.insert(coords, tonumber(num))
    end
  else
    -- If the part is a single number (e.g., "2")
    table.insert(coords, tonumber(coord_str))
  end
  -- Return the array of coordinates
  return coords
end

-- Setup function
function M.setup()
  -- Example: Set up keymaps, commands, etc.
  vim.api.nvim_set_keymap('n', '<leader>tc', ':lua require("nvim-tablecalc").read_buffer_normal()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<leader>tc', ':lua require("nvim-tablecalc").read_buffer_visual()<CR>',
    { noremap = true, silent = true })
end

-- Create the custom command :TableSum
vim.api.nvim_create_user_command('TableSum', function(opts)
  -- Split the arguments into x_coords and y_coords
  local args = opts.args
  local x_coords, y_coords = args:match("([^ ]+) ([^ ]+)") -- Match two space-separated arguments

  if not x_coords or not y_coords then
    print("Error: Invalid arguments. Expected two arguments: x_coords and y_coords.")
    return
  end

  -- Call the sum function with the extracted arguments
  M.sum(x_coords, y_coords)
end, { nargs = 1 }) -- Expect one argument containing both x_coords and y_coords

return M
