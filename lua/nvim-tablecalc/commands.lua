-- lua/nvim-tablecalc/commands.lua

---@class Commands
local Commands = {}
Commands.__index = Commands

--- Constructor for Commands class
---@return Commands A new instance of the Commands class
function Commands.new()
  local self = setmetatable({}, Commands)
  return self
end

--- Setup method to map keybindings for normal and visual modes
function Commands.setup()
  -- Key mapping for normal mode
  vim.api.nvim_set_keymap('n', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance():run_normal()<CR>',
    { noremap = true, silent = true })

  -- Key mapping for visual mode
  vim.api.nvim_set_keymap('v', '<leader>tc',
    ':lua require("nvim-tablecalc").get_instance():run_visual()<CR>',
    { noremap = true, silent = true })

  vim.api.nvim_create_user_command('TableCreate', function(opts)
    local args = opts.args
    local rows, cols, headers = args:match("([^ ]+) ([^ ]+) ?([^ ]*)")
    print(rows)
    print(cols)
    print(headers)

    require("nvim-tablecalc").get_instance():get_utils():insert_table(rows, cols, headers)
  end, { nargs = '*' })
end

return Commands
