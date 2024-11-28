local luaunit = require('luaunit')

local TableCalc = _G.TableCalc
local Parsing = TableCalc.get_instance():get_parsing()

-- Defining the test suite
TestParsing = {}

function TestParsing:setUp()
  -- Save the original _G.vim value
  self.original_vim = _G.vim
  -- Mock filetype to not get nil in Config:get_table_name_marker()
  _G.vim = {
    bo = { filetype = "org" }
  }

  -- Expected output table (kept as it is)
  self.expected_output = {
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
end

function TestParsing:test_parse_structured_table_with_complex_data()
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

  -- Act: Call the method with input data
  local result = Parsing:parse_structured_table(input)

  -- Assert
  luaunit.assertEquals(result, self.expected_output,
    "parse_structured_table should return the expected complex structured data")
end

function TestParsing:test_parse_headers()
  -- Act: Call the method with input data
  local result = Parsing:parse_headers("Name n, Price p,fnord")

  -- Assert: Verify that the result matches the expected output
  luaunit.assertEquals(result, { "Name n", "Price p", "fnord" },
    "parse_headers should return the expected table")
end

function TestParsing:test_process_data()
  -- mock vim.pesc
  _G.vim = {
    pesc = function(str)
      return str:gsub("([^%w])", "%%%1")
    end
  }

  -- Act: Call the method with input data
  local result = Parsing:process_data(self.expected_output)
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

-- Restore the original _G.vim value after the test
function TestParsing:tearDown()
  _G.vim = self.original_vim
end
