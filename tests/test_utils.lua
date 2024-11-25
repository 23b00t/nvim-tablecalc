local luaunit = require('luaunit')

-- Extending package.path to correctly set the directory for modules
package.path = package.path ..
    ";/home/user/code/lua/nvim-tablecalc/lua/?.lua;/home/user/code/lua/nvim-tablecalc/lua/?/init.lua"
local TableCalc = require('nvim-tablecalc.init')
local Utils = TableCalc.get_instance():get_utils()

-- Defining the test suite
TestUtils = {}

function TestUtils:test_stripe()
  -- Act: Call the method with different inputs
  local result1 = Utils.stripe("  leading and trailing spaces  ")
  local result2 = Utils.stripe("no spaces")
  local result3 = Utils.stripe("    ")
  -- Suppress the type mismatch warning for the next line
  ---@diagnostic disable-next-line: param-type-mismatch
  local result4 = Utils.stripe(nil)

  -- Assert: Verify the expected results
  luaunit.assertEquals(result1, "leading and trailing spaces",
    "stripe should trim leading and trailing spaces")
  luaunit.assertEquals(result2, "no spaces",
    "stripe should return the string unchanged if no spaces are present")
  luaunit.assertEquals(result3, "",
    "stripe should return an empty string for strings with only spaces")
  luaunit.assertEquals(result4, "",
    "stripe should return an empty string when input is nil")
end

function TestUtils:test_sum()
  -- Arrange: Define test data
  local data1 = {1, 2, 3, 4, 5} -- Valid numeric data
  local data2 = {"1", "2", "3"} -- String representations of numbers
  local data3 = {1, "a", 2, "b", 3} -- Mixed data
  local data4 = {} -- Empty table

  -- Act: Call the method with test data
  local result1 = Utils:sum(data1)
  local result2 = Utils:sum(data2)
  local result3 = Utils:sum(data3)
  local result4 = Utils:sum(data4)

  -- Assert: Verify the expected results
  luaunit.assertEquals(result1, 15,
    "sum should return the sum of all numeric values in the table")
  luaunit.assertEquals(result2, 6,
    "sum should correctly handle numeric strings as input")
  luaunit.assertEquals(result3, 6,
    "sum should ignore non-numeric values in the table")
  luaunit.assertEquals(result4, 0,
    "sum should return 0 for an empty table")
end

function TestUtils:test_mul()
  -- Arrange: Define test data
  local data1 = {1, 2, 3, 4, 5} -- Valid numeric data
  local data2 = {"1", "2", "3"} -- String representations of numbers
  local data3 = {1, "a", 2, "b", 3} -- Mixed data
  local data4 = {} -- Empty table
  local data5 = {0, 1, 2, 3} -- Includes zero

  -- Act: Call the method with test data
  local result1 = Utils:mul(data1)
  local result2 = Utils:mul(data2)
  local result3 = Utils:mul(data3)
  local result4 = Utils:mul(data4)
  local result5 = Utils:mul(data5)

  -- Assert: Verify the expected results
  luaunit.assertEquals(result1, 120,
    "mul should return the product of all numeric values in the table")
  luaunit.assertEquals(result2, 6,
    "mul should correctly handle numeric strings as input")
  luaunit.assertEquals(result3, 6,
    "mul should ignore non-numeric values in the table")
  luaunit.assertEquals(result4, 1,
    "mul should return 1 for an empty table, as it represents the multiplicative identity")
  luaunit.assertEquals(result5, 0,
    "mul should return 0 if the table contains a zero")
end
