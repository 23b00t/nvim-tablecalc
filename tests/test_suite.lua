-- Central test runner to include all the individual test files

-- Require LuaUnit
local luaunit = require('luaunit')
-- Extending package.path to correctly set the directory for modules
package.path = package.path ..
    ";/home/user/code/lua/nvim-tablecalc/lua/?.lua;/home/user/code/lua/nvim-tablecalc/lua/?/init.lua"

-- Include all the individual test files
require('tests.test_tablecalc')
require('tests.test_parsing')

-- Run the tests
os.exit(luaunit.LuaUnit.run())