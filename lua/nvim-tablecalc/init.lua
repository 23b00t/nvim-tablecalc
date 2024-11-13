-- lua/nvim-tablecalc/init.lua

local M = {}
local config = require('nvim-tablecalc.config')  -- Load configuration

-- Function to read the current buffer
function M.read_buffer()
  -- Get the entire buffer content as a string
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')  -- Join lines to a single string
  
  -- Call a function to parse the table (assuming you have a parser)
  M.parse_table(content)
end

-- Function to parse the table from the buffer content
function M.parse_table(content)
  -- Example: Split the content by lines and then by the delimiter (e.g., '|')
  local rows = {}
  for line in content:gmatch("[^\r\n]+") do
    local columns = {}
    for col in line:gmatch("[^" .. config.delimiter .. "]+") do
      table.insert(columns, col)
    end
    table.insert(rows, columns)
  end

  -- You can now process `rows`, which is a 2D table of the parsed content
  -- Example: Print the parsed table (for testing)
  for _, row in ipairs(rows) do
    print(vim.inspect(row))
  end
end

-- Setup function
function M.setup()
  -- Example: Set up keymaps, commands, etc.
  vim.api.nvim_set_keymap('n', '<leader>tc', ':lua require("nvim-tablecalc").read_buffer()<CR>', { noremap = true, silent = true })
end

return M
