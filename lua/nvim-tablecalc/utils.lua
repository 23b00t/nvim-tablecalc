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
  for table_name, table_content in pairs(table_data) do
    for column, values in pairs(table_content) do
      for i, cell in ipairs(values) do
        -- print(vim.inspect(table_name))
        -- error()
        -- Detect if the cell contains a formula
        local match_expr = "^%" .. self.config.formula_begin .. "(.+)%" .. self.config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Avoid recursive self call by checking if current cell is part of the formula
          if formula:match(table_name .. '.' .. column .. '.' .. i) then
            error('No recurisve self calls!!!!!')
          else
            -- Evaluate the formula and append the result to the cell
            local result = self:evaluate_formula(cell)
            table_content[column][i] = self.config.formula_begin .. formula .. self.config.formula_end .. ": " .. result
          end
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
  if expression:match("[^%.%s0-9%+%*%-%/%^]+") then
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
      return self:resolve_expression(match)
    end)
    return self:resolve_recursive(expression)
  end
  -- clear intermediat results (: %d+) from the string
  expression = expression:gsub(":%s*[%d%.]*", '')
  return expression
end

--- Resolves references in a formula to their corresponding values
---@param expression string The expression containing references to be resolved
function Utils:resolve_expression(expression)
  -- Resolve "sum" expressions
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
    return self:sum()
  end)

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

-- Utility function to parse a string into a Lua table
---@param headers string
---@return table
function Utils:parse_headers(headers)
    if type(headers) == "string" then
        local parsed = {}
        for header in headers:gmatch("[^,]+") do
            table.insert(parsed, header:match("^%s*%{*(.-)%}*%s*$")) -- Trim whitespace
        end
        return parsed
    end
    return headers -- If already a table, return as-is
end

-- Function to insert a table with rows, columns, and optional headers
---@param rows string
---@param cols string
---@param headers string
-- INFO: Example usage
-- insert_table(3, 3) -- Table with 3 rows, 3 columns, no headers
-- insert_table(3, 3, {Name,Age,City}) -- Table with headers
function Utils:insert_table(rows, cols, headers)
  local tbl = {}

  local headers_table = self:parse_headers(headers)
  -- Check if headers are provided
  local use_headers = type(headers_table) == "table" and #headers > 0

  -- Create the header row (always empty if no headers are provided)
  local header = { "#" } -- Placeholder for the numbered column
  for c = 1, cols do
    table.insert(header, use_headers and (headers_table[c] or "") or " ")
  end

  table.insert(tbl, "| " .. table.concat(header, " | ") .. " |")
  table.insert(tbl, "|" .. string.rep("-----|", cols + 1)) -- Separator row

  -- Create data rows
  for r = 1, rows do
    local row = { tostring(r) } -- Numbered first column
    for _ = 1, cols do
      table.insert(row, " ")    -- Empty cells
    end
    table.insert(tbl, "| " .. table.concat(row, " | ") .. " |")
  end

  -- Insert the table into the current buffer
  vim.api.nvim_put(tbl, "l", true, true)

  -- Run autoformat command after writing to the buffer
  vim.cmd(self.config:autoformat_buffer())
end

-- Define a function to highlight '{}' and their contents
function Utils:highlight_curly_braces()
  -- Define the highlighting group
  vim.api.nvim_set_hl(0, "PurpleCurly", { fg = "#b279d2" }) -- Adjust the color as needed

  -- Add the match for formula markers and their contents, not match pipe to avoid matching the closing tag of the next cell
  vim.fn.matchadd("PurpleCurly", self.config.formula_begin .. "[^|]*" .. self.config.formula_end)
end

return Utils
