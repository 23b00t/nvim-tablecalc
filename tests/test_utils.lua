local luaunit = require('luaunit')

local Utils = require('nvim-tablecalc.utils')

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
