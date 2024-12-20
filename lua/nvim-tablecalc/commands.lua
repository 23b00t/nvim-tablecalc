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

  vim.api.nvim_create_user_command('TableCreate', function(opts)
    local args = opts.args
    local cols, rows, headers = args:match("(%d+)%s+(%d+)%s*(.*)")

    require("nvim-tablecalc").get_instance():get_core():insert_table(cols, rows, headers)
  end, { nargs = '*' })

  -- Create autocommands for both buffer opening and text changes
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    -- TODO: Should be dynamic --> related to plugin/nvim-tablecalc.lua
    pattern = { "*.org", "*.md" },
    callback = function()
      require('nvim-tablecalc').get_instance():get_core():highlight_curly_braces()
    end,
  })

  -- Create autocommand to remove highlighting by leaving the buffer
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    pattern = { "*.org", "*.md" },
    callback = function()
      require('nvim-tablecalc').get_instance():get_core():remove_highlight()
    end,
  })
end

return Commands
