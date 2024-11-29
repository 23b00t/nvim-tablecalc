-- lua/nvim-tablecalc/parsing.lua

---@class Parsing
---@field table_calc_instance TableCalc Instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field utils Utils Utility functions for parsing
---@field rows table A table storing parsed rows, structured by table names and headers
local Parsing = {}

Parsing.__index = Parsing

--- Creates a new instance of Parsing
---@param table_calc_instance TableCalc The instance of the TableCalc class
---@return Parsing A new instance of the Parsing class
function Parsing.new(table_calc_instance)
  local self = setmetatable({}, Parsing)
  -- Store the reference to the TableCalc instance
  self.table_calc_instance = table_calc_instance
  -- Get the configuration and utilities from the TableCalc instance
  self.config = self.table_calc_instance:get_config()
  self.utils = self.table_calc_instance:get_utils()
  self.rows = {} -- Initialize an empty table to store rows
  return self
end

--- Parses a structured table with headers and stores it in a nested format
---@param content string The content to be parsed, containing table data
---@return table: The parsed rows stored in a nested table format
function Parsing:parse_structured_table(content)
  local current_table_name = "" -- Variable to track the current table name
  local headers = {}            -- Array to store the column headers of the current table
  -- Split content into lines and process each line
  for line in content:gmatch("[^\r\n]+") do
    -- Detect table names, marked by a line starting with `#`
    if line:match("^" .. self.config:get_table_name_marker()) then
      -- Extract the table name (last word after the `#`)
      current_table_name = line:match(self.config:get_table_name_marker() .. "%s*.-%s(%w+)%s*$")
      self.rows[current_table_name] = {} -- Initialize a table for the extracted table name
      headers = {}                       -- Reset headers for the new table
    elseif line:find(self.config.delimiter) and line:find("%w") then
      -- If headers are not set, parse the current line as the header row
      if #headers == 0 then
        for header in line:gmatch(self.config.delimiter .. "%s*([^" .. self.config.delimiter .. "]+)%s*") do
          -- Extract and clean the header, then store it
          header = header:match("%s*(%w+)%s*$")
          table.insert(headers, self.utils.stripe(header))              -- Clean and add header
          self.rows[current_table_name][self.utils.stripe(header)] = {} -- Create sub-tables for headers
        end
      else
        -- Parse table rows and map values to their corresponding headers
        local row_index = tonumber(line:match(self.config.delimiter .. "%s*(%d+)")) -- Extract the row index
        local col_index = 1                                                         -- Track the column index for mapping
        for value in line:gmatch(self.config.delimiter .. "%s*([^" .. self.config.delimiter .. "]+)%s*") do
          local header = headers[col_index]
          if row_index then
            -- Map the value to the correct header and row index
            self.rows[current_table_name][header][row_index] = self.utils.stripe(value)
          end
          col_index = col_index + 1 -- Move to the next column
        end
      end
    end
  end
  -- After parsing the structured table, return the parsed rows
  return self.rows
end

-- Utility function to parse a string into a Lua table
---@param headers string
---@return table
function Parsing:parse_headers(headers)
  if type(headers) == "string" then
    local parsed = {}
    for header in headers:gmatch("[^,]+") do
      table.insert(parsed, header:match("^%s*%{*(.-)%}*%s*$")) -- Trim whitespace
    end
    return parsed
  end
  return headers -- If already a table, return as-is
end

--- Extracts and evaluates formulas from a table and appends the result
---@param table_data table The table containing data to be processed
---@return table The updated table with formula results appended to the cells
function Parsing:process_data(table_data)
  local results = {}
  self.rows = table_data -- Use the table data for processing
  -- Iterate through all tables and their columns
  for table_name, table_content in pairs(table_data) do
    -- Save table name for later use in self:resolve_expression
    self.table_name = table_name
    for column, values in pairs(table_content) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula
        local match_expr = "^%" .. self.config.formula_begin .. "(.+)%" .. self.config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Avoid recursive self call by checking if current cell is part of the formula
          if formula:match(table_name .. '.' .. column .. '.' .. i) then
            error('No recurisve self calls!')
          else
            -- Evaluate the formula and append the result to the cell
            local result = self:evaluate_formula(cell)
            -- Give back 0 if result is nil i.e. only a cell containing a word was referenced
            -- in a formula, which means an empty string was evaluated by load
            table.insert(results,
              self.config.formula_begin .. formula .. self.config.formula_end .. ": " .. (result or 0))
          end
        end
      end
    end
  end
  -- Return a table only with formula: result
  return results
end

--- Evaluates a mathematical formula
---@param formula string The formula to be evaluated
---@return any: The result of the evaluated formula
function Parsing:evaluate_formula(formula)
  -- Resolve references in the formula to their actual values
  local expression = self:resolve_recursive(formula)
  local simplifyed_expression = self.utils:simplify_expression(expression)
  -- TODO: if simplifyed_expression == "" then return expression end
  -- If the cell only contains non numeric or mathematical expressions, simplify_expression will return empty.
  -- Than just directly return the expression as result, i.e. the word written in the cell
  -- It should be decided if this would be a feature.

  -- Load and execute the expression in the Lua environment if it is a math expression
  local func, err = load("return " .. simplifyed_expression)
  if func then
    return func() -- Execute and return the result
  else
    error("Error in evaluating formula:" .. err)
  end
end

--- Resolves expressions recursivly until no more formulas are found
---@param expression string
---@return string expression
function Parsing:resolve_recursive(expression)
  local match_expr = "%" .. self.config.formula_begin .. "([%w%d%.%s%+%*%-%/%(%)%,]+)%" .. self.config.formula_end
  if expression:match(match_expr) then
    expression = expression:gsub(match_expr, function(match)
      return self:resolve_expression(match)
    end)
    return self:resolve_recursive(expression)
  end
  -- clear intermediat results (: %d+) from the string
  expression = expression:gsub(":%s*-?[%d%.]*", '')
  return expression
end

--- Resolves references in a formula to their corresponding values
---@param expression string The expression containing references to be resolved
function Parsing:resolve_expression(expression)
  -- Resolve sum and mul expressions (get data to sum or multiply columns or rows)
  -- INFO: mum and sul do the same as mul, but maybe it's a feature, fnord
  local modified_expression = expression:gsub("([sm]u[ml])%((%w+),%s*(%w+),?%s*(%d*)%)",
    function(operation, table_name, column_name, row_index)
      local data = {}
      if row_index == '' then
        data = self.rows[table_name][column_name]
      elseif column_name == 'nil' then
        data = {}
        local table_data = self.rows[table_name] -- Get the table data by name
        for header, column in pairs(table_data) do
          if not header:match("^%s*$") then
            table.insert(data, column[tonumber(row_index)]) -- Insert the value from the specific field into data
          end
        end
      end
      -- Convert data to a mathematical expression and remove the calling expression from it
      local operator = operation == "sum" and "+" or "*"
      return table.concat(data, operator):gsub(vim.pesc(expression), "")
    end)

  -- Only execute the second block if no changes were made in the first
  if modified_expression == expression then
    -- Replace references like Table.Column.Row with actual values
    modified_expression = modified_expression:gsub("(%w*)%.?(%w+).(%d+)", function(table_name, column_name, row_index)
      -- Use `self.table_name` if the table name is missing, which means: refer to the calling table
      if table_name == "" then table_name = self.table_name end
      local table_data = self.rows[table_name] -- Get the table data by name
      if table_data and table_data[column_name] then
        local row_value = table_data[column_name][tonumber(row_index)]
        -- if the value is not empty return it as string else return '0' (to handle empty fields as 0)
        return row_value ~= '' and tostring(row_value) or '0' -- Convert the value to a string for Lua expressions
      end
    end)
  end

  return modified_expression
end

return Parsing
