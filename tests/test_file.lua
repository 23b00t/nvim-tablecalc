local luaunit = require('luaunit')
local TableCalc = require('../lua/nvim-tablecalc')

TestTableCalc = {}

function TestTableCalc:test_get_instance()
  local instance = TableCalc.get_instance()
  luaunit.assertNotNil(instance)
end

function TestTableCalc:test_new_instance()
  local instance = TableCalc.new()
  luaunit.assertNotNil(instance)
end

luaunit.run()
