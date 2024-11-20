-- lua/nvim-tablecalc/utils.lua

---@class Utils
---@field table_calc_instance TableCalc The instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field rows table A table to store rows for processing
local Utils = {}

Utils.__index = Utils

--- Creates a new instance of Utils
---@param table_calc_instance TableCalc The instance of the TableCalc class
---@return Utils A new instance of the Utils class
function Utils.new(table_calc_instance)
  local self = setmetatable({}, Utils)
  -- Store the reference to the TableCalc instance
  self.table_calc_instance = table_calc_instance
  -- Get the configuration from the TableCalc instance
  self.config = self.table_calc_instance:get_config()
  self.rows = {} -- Initialize rows for processing
  return self
end

--- Extracts and evaluates formulas from a table and appends the result
---@param table_data table The table containing data to be processed
---@return table The updated table with formula results appended to the cells
function Utils:process_data(table_data)
  self.rows = table_data -- Use the table data for processing
  -- Iterate through all tables and their columns
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula
        local match_expr = "^%" .. self.config.formula_begin .. "(.+)%" .. self.config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Evaluate the formula and append the result to the cell
          local result = self:evaluate_formula(cell)
          table_name[column][i] = self.config.formula_begin .. formula .. self.config.formula_end .. ": " .. result
        end
      end
    end
  end
  -- Return the updated table data with results
  return self.rows
end

--- Evaluates a mathematical formula
---@param formula string The formula to be evaluated
---@return any The result of the evaluated formula
function Utils:evaluate_formula(formula)
  -- Resolve references in the formula to their actual values
  local expression = self:resolve_recursive(formula)
  -- Load and execute the expression in the Lua environment if it is a math expression
  if expression:match("[^%s0-9%+%*%-%/%^]+") then
    print("Only math is allowed, you expression is: ", expression)
  else
    local func, err = load("return " .. expression)
    if func then
      return func() -- Execute and return the result
    else
      print("Error in evaluating formula:", err)
    end
  end
end

--- Resolves expressions recursivly until no more formulas are found
---@param expression string
---@return string expression
function Utils:resolve_recursive(expression)
  local match_expr = "%" .. self.config.formula_begin .. "([%w%d%.%s%+%*%-%/%(%)%,]+)%" .. self.config.formula_end
  if expression:match(match_expr) then
    expression = expression:gsub(match_expr, function(match)
      if match:match("sum") then
        self:resolve_sum_expression(match)
        return self:sum()
      else
        return self:resolve_expression(match)
      end
    end)
    return self:resolve_recursive(expression)
  end
  -- clear intermediat results from the string
  expression = expression:gsub(":%s*%d+", '')
  return expression
end

--- Resolves references in a formula to their corresponding values
---@param expression string The expression containing references to be resolved
function Utils:resolve_sum_expression(expression)
  -- Resolve "sum" expressions
  expression:gsub("sum%((%w+),%s*(%w+),?%s*(%d*)%)", function(table_name, column_name, row_index)
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
  end)
end

--- Resolves references in a formula to their corresponding values
---@param expression string The expression containing references to be resolved
---@return string The resolved expression with actual values
function Utils:resolve_expression(expression)
  -- Replace references like Table.Column.Row with actual values
  expression = expression:gsub("(%w+).(%w+).(%d+)", function(table_name, column_name, row_index)
    local table_data = self.rows[table_name] -- Get the table data by name
    if table_data and table_data[column_name] then
      local row_value = table_data[column_name][tonumber(row_index)]
      return tostring(row_value) -- Convert the value to a string for Lua expressions
    else
      error("Invalid reference: ")
    end
  end)

  return expression
end

--- Utility function to trim whitespace from strings
---@param str string The string to be trimmed
---@return string The trimmed string
function Utils.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

--- Sums the values in the data table
---@return number The sum of the values
function Utils:sum()
  local sum = 0
  -- Iterate through the data and sum the numeric values
  for i = 1, #self.data do
    if tonumber(self.data[i]) then
      sum = sum + tonumber(self.data[i])
    end
  end
  return sum
end

return Utils
