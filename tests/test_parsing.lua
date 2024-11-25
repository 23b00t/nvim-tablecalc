local luaunit = require('luaunit')

local TableCalc = _G.TableCalc
local Parsing = TableCalc.get_instance():get_parsing()

-- Defining the test suite
TestParsing = {}

local input = [[
* My table
# Super as S
|   | Name  | Count c | Price | Sum              |
|---+-------+---------+-------+------------------|
| 1 | Item  | 3       | 5     |                  |
| 2 | Fish  | 5       | 23    | {sum(S, nil, 2)} |
| 3 | Apple | 23      | 5     | { 3 * 3}         |
| 4 | Sum   |         |       |                  |

* Insert some text
** With stuff
- TAUG GRAGIT ERIS, TAUG GRAGTI DISCORDIA

* Other table
# Toll as t
|   | Test  | Num as N    |
|---+-------+-------------|
| 1 | Item  | 5           |
| 2 | Fish  | 5           |
| 3 | Apple | 23          |
| 4 | sum   | {sum(t, N)} |

* An other other table
# table
|   | Name  | Sum             |
|---+-------+-----------------|
| 1 | Super | {S.c.3 + S.c.2} |
| 2 | Toll  | { 3 + 5}        |
]]

-- Expected output table (kept as it is)
local expected_output = {
  S = {
    [""] = { "1", "2", "3", "4" },
    Name = { "Item", "Fish", "Apple", "Sum" },
    Price = { "5", "23", "5", "" },
    Sum = { "", "{sum(S, nil, 2)}", "{ 3 * 3}", "" },
    c = { "3", "5", "23", "" }
  },
  t = {
    [""] = { "1", "2", "3", "4" },
    N = { "5", "5", "23", "{sum(t, N)}" },
    Test = { "Item", "Fish", "Apple", "sum" }
  },
  table = {
    [""] = { "1", "2" },
    Name = { "Super", "Toll" },
    Sum = { "{S.c.3 + S.c.2}", "{ 3 + 5}" }
  }
}

function TestParsing:tables_are_equal(t1, t2)
  if t1 == t2 then return true end -- Referenzgleichheit

  if type(t1) ~= "table" or type(t2) ~= "table" then
    return false
  end

  for key, value in pairs(t1) do
    if not TestParsing:tables_are_equal(value, t2[key]) then
      return false
    end
  end

  for key, value in pairs(t2) do
    if not TestParsing:tables_are_equal(value, t1[key]) then
      return false
    end
  end

  return true
end

function TestParsing:test_parse_structured_table_with_complex_data()
  -- Save the original _G.vim value
  local original_vim = _G.vim
  -- Mock filetype to not get nil in Config:get_table_name_marker()
  _G.vim = {
    bo = { filetype = "org" }
  }

  -- Act: Call the method with input data
  local result = Parsing:parse_structured_table(input)

  -- Assert: Überprüfen, ob das Ergebnis mit der erwarteten Ausgabe übereinstimmt
  luaunit.assertTrue(TestParsing:tables_are_equal(result, expected_output),
    "parse_structured_table should return the expected complex structured data")

  -- Restore the original _G.vim value after the test
  _G.vim = original_vim
end

function TestParsing:test_parse_headers()
  -- Act: Call the method with input data
  local result = Parsing:parse_headers("Name n, Price p,fnord")

  -- Assert: Verify that the result matches the expected output
  luaunit.assertEquals(result, {"Name n", "Price p", "fnord"},
    "parse_headers should return the expected table")
end

function TestParsing:test_process_data()
  -- Act: Call the method with input data
  local result = Parsing:process_data(expected_output)
  local expected = {
       "{sum(S, nil, 2)}: 28",
       "{ 3 * 3}: 9",
       "{sum(t, N)}: 33",
       "{S.c.3 + S.c.2}: 28",
       "{ 3 + 5}: 8"
  }

  -- Assert: Verify that the result contains the same elements as expected, regardless of order
  table.sort(result)
  table.sort(expected)
  luaunit.assertEquals(result, expected,
    "process_data should return the expected table, regardless of order")
end
