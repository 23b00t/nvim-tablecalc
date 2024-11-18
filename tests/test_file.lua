local luaunit = require('luaunit')

-- Extending package.path to correctly set the directory for modules
package.path = package.path .. ";/home/user/code/lua/nvim-tablecalc/lua/?.lua;/home/user/code/lua/nvim-tablecalc/lua/?/init.lua"
local TableCalc = require('lua/nvim-tablecalc.init')

-- Defining the test suite
TestTableCalc = {}

-- Test 1: Check if the instance of TableCalc is created correctly
function TestTableCalc:test_get_instance()
  local instance = TableCalc.get_instance()
  luaunit.assertNotNil(instance)  -- Assert the instance is not nil
end

-- Test 2: Check if a new instance of TableCalc can be created correctly
function TestTableCalc:test_new_instance()
  local instance = TableCalc.new()
  luaunit.assertNotNil(instance)  -- Assert the new instance is not nil
end

-- Run the tests
luaunit.run()
