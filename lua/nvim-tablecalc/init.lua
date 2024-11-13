-- lua/nvim-tablecalc/init.lua
local M = {}

local commands = require('nvim-tablecalc.commands')

function M.setup()
  commands.setup() -- Setup keymaps and commands
end

return M
