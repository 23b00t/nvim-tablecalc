-- lua/nvim-tablecalc/commands.lua
local M = {}

function M.setup()
  vim.api.nvim_set_keymap('n', '<leader>tc', ':lua require("nvim-tablecalc.core").read_buffer_normal()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<leader>tc', ':lua require("nvim-tablecalc.core").read_buffer_visual()<CR>', { noremap = true, silent = true })

  vim.api.nvim_create_user_command('TableSum', function(opts)
    local args = opts.args
    local x_coords, y_coords = args:match("([^ ]+) ([^ ]+)")
    if not x_coords or not y_coords then
      print("Error: Invalid arguments. Expected two arguments: x_coords and y_coords.")
      return
    end
    require('nvim-tablecalc.utils').sum(x_coords, y_coords)
  end, { nargs = 1 })
end

return M
