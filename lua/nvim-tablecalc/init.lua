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
  local rows = {}
  for line in content:gmatch("[^\r\n]+") do
    if line:find("[a-zA-Z0-9]") and line:find(config.delimiter) then
      local columns = {}
      for col in line:gmatch("[^" .. config.delimiter .. "]+") do
        table.insert(columns, col)
      end
      table.insert(rows, columns)
    end
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
  vim.api.nvim_set_keymap('n', '<leader>tc', ':lua require("nvim-tablecalc").read_buffer_normal()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<leader>tc', ':lua require("nvim-tablecalc").read_buffer_visual()<CR>',
    { noremap = true, silent = true })
end

return M
