-- lua/nvim-tablecalc/utils.lua
local Utils = {}
-- local config = require('nvim-tablecalc.config').new()

Utils.__index = Utils

-- Create a new Utils self
function Utils.new(table_calc_instance)
  local self = setmetatable({}, Utils)
  self.table_calc_instance = table_calc_instance
  self.config = self.table_calc_instance:get_config()
  self.rows = {}  -- Initialize rows for each self
  return self
end

-- Extracts and evaluates formulas from a table and appends the result
function Utils:process_data(table_data)
  self.rows = table_data  -- Verwende die Singleton-Instanz
  -- Iterate through all tables and their columns
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula (starts with `=`)
        local match_expr = "^%" .. self.config.formula_begin .. "(.+)%" .. self.config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Evaluate the formula and append the result to the cell
          local result = self:evaluate_formula(formula)
          table_name[column][i] = self.config.formula_begin .. formula .. self.config.formula_end .. ": " .. result
        end
      end
    end
  end
  -- return table_data -- Return the updated table data
  -- self:write_to_buffer(self.rows)
  return self.rows
end

-- Evaluates a mathematical formula
function Utils:evaluate_formula(formula)
  -- Resolve references in the formula to their actual values
  local expression = self:resolve_expression(formula)

  if expression:match("sum") then
    return self:sum()
  end
  -- Load the expression in the context of the environment
  local func, err = load("return " .. expression)
  if func then
    return func() -- Führe die Funktion aus und gib das Ergebnis zurück
  else
    print("Error in evaluating formula:", err)
  end
end

-- Resolves references in a formula to their corresponding values
function Utils:resolve_expression(expression)
  expression = expression:gsub("sum%((%w+),%s*(%w+),?%s*(%d*)%)", function(table_name, column_name, row_index)
    if row_index == '' then
      self.data = self.rows[table_name][column_name]
    elseif column_name == 'nil' then
      self.data = {}
      local table_data = self.rows[table_name] -- Get the table data by name
      for header, column in pairs(table_data) do
        if not header:match("^%s*$") then
          table.insert(self.data, column[tonumber(row_index)]) -- Insert the value from the specific field into self.data
        end
      end
    end
    return "Utils.sum"
  end)

  -- Replace references of the form Table.Column.Row with actual values
  return expression:gsub("(%w+).(%w+).(%d+)", function(table_name, column_name, row_index)
    local table_data = self.rows[table_name] -- Get the table data by name
    if table_data and table_data[column_name] then
      local row_value = table_data[column_name][tonumber(row_index)]
      return tostring(row_value) -- Convert the value to a string for Lua expressions
    else
      error("Invalid reference: ")
    end
  end)
end

-- Utility function to trim whitespace from strings
function Utils.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

-- Sum columns
function Utils:sum()
  local sum = 0
  for i = 1, #self.data do
    if tonumber(self.data[i]) then
      sum = sum + tonumber(self.data[i])
    end
  end
  return sum
end

return Utils
