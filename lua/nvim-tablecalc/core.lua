-- lua/nvim-tablecalc/core.lua
local utils = require('nvim-tablecalc.utils')
local M = {}

function M.read_buffer_normal()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  utils.parse_table(content)
end

function M.read_buffer_visual()
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')

  if start_pos[1] > end_pos[1] then
    print("Invalid visual selection")
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  local content = table.concat(lines, '\n')
  utils.parse_table(content)
end

return M
