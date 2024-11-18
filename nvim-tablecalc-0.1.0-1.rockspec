package = "nvim-tablecalc"
version = "0.1.0-1"
source = {
   url = "git+ssh://git@github.com/23b00t/nvim-tablecalc.git"
}
description = {
   detailed = [[
## Description
- My first experiments with Lua
- Goal: Implement basic table calculations within Vim]],
   homepage = "https://github.com/23b00t/nvim-tablecalc",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.5"
}
build = {
   type = "builtin",
   modules = {
      ["nvim-tablecalc.commands"] = "lua/nvim-tablecalc/commands.lua",
      ["nvim-tablecalc.config"] = "lua/nvim-tablecalc/config.lua",
      ["nvim-tablecalc.core"] = "lua/nvim-tablecalc/core.lua",
      ["nvim-tablecalc.init"] = "lua/nvim-tablecalc/init.lua",
      ["nvim-tablecalc.parsing"] = "lua/nvim-tablecalc/parsing.lua",
      ["nvim-tablecalc.utils"] = "lua/nvim-tablecalc/utils.lua"
   },
   copy_directories = {
      "tests"
   }
}
