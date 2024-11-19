local luaunit = require('luaunit')

-- Extending package.path to correctly set the directory for modules
package.path = package.path ..
    ";/home/user/code/lua/nvim-tablecalc/lua/?.lua;/home/user/code/lua/nvim-tablecalc/lua/?/init.lua"
local TableCalc = require('lua/nvim-tablecalc.init')

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
  -- Instanz erstellen und den Mock verwenden
  local instance = TableCalc.get_instance()

  -- Act: Aufruf der Methode mit Input-Daten
  local result = instance.parsing:parse_structured_table(input)

  -- Assert: Überprüfen, ob das Ergebnis mit der erwarteten Ausgabe übereinstimmt
  luaunit.assertTrue(TestParsing:tables_are_equal(result, expected_output),
    "parse_structured_table should return the expected complex structured data")
end
