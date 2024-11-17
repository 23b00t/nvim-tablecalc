-- lua/nvim-tablecalc/utils.lua
local Utils = {}

local config = require('nvim-tablecalc.config').new()  -- Erstelle eine Instanz von Config

Utils.__index = Utils
local instance = nil

-- Singleton-Methode: Gibt immer dieselbe Instanz zurück
function Utils.get_instance()
  if not instance then
    instance = Utils.new()
  end
  return instance
end

-- Konstruktor
function Utils.new()
  local self = setmetatable({}, Utils)
  self.rows = {}  -- Initialisiere die Zeilen für jede Instanz
  return self
end

-- Extracts and evaluates formulas from a table and appends the result
function Utils.process_data(table_data)
  local instance = Utils.get_instance()  -- Holen der Singleton-Instanz
  instance.rows = table_data  -- Verwende die Singleton-Instanz
  -- Iterate through all tables and their columns
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula (starts with `=`)
        local match_expr = "^%" .. config.formula_begin .. "(.+)%" .. config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Evaluate the formula and append the result to the cell
          local result = instance.evaluate_formula(formula)
          table_name[column][i] = config.formula_begin .. formula .. config.formula_end .. ": " .. result
        end
      end
    end
  end
  return table_data -- Return the updated table data
end

-- Evaluates a mathematical formula
function Utils.evaluate_formula(formula)
  local instance = Utils.get_instance()  -- Holen der Singleton-Instanz
  -- Resolve references in the formula to their actual values
  local expression = instance.resolve_expression(formula)

  if expression:match("sum") then
    return instance.sum()
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
function Utils.resolve_expression(expression)
  local instance = Utils.get_instance()  -- Holen der Singleton-Instanz
  expression = expression:gsub("sum%((%w+),%s*(%w+),?%s*(%d*)%)", function(table_name, column_name, row_index)
    if row_index == '' then
      instance.data = instance.rows[table_name][column_name]
    elseif column_name == 'nil' then
      instance.data = {}
      local table_data = instance.rows[table_name] -- Get the table data by name
      for header, column in pairs(table_data) do
        if not header:match("^%s*$") then
          table.insert(instance.data, column[tonumber(row_index)]) -- Insert the value from the specific field into instance.data
        end
      end
    end
    return "Utils.sum"
  end)

  -- Replace references of the form Table.Column.Row with actual values
  return expression:gsub("(%w+).(%w+).(%d+)", function(table_name, column_name, row_index)
    local table_data = instance.rows[table_name] -- Get the table data by name
    if table_data and table_data[column_name] then
      local row_value = table_data[column_name][tonumber(row_index)]
      return tostring(row_value) -- Convert the value to a string for Lua expressions
    else
      error("Invalid reference: ")
    end
  end)
end

-- Writes the modified table data back to the buffer
function Utils.write_to_buffer(table_data)
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      for _, cell_content in pairs(rows) do
        local formula, result = cell_content:match("^(%" ..
          config.formula_begin .. ".-%" .. config.formula_end .. "): (.+)$")
        if formula and result then
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break
            end
          end
        end
      end
    end
  end
end

-- Utility function to trim whitespace from strings
function Utils.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

-- Sum columns
function Utils.sum()
  local sum = 0
  for i = 1, #instance.data do
    if tonumber(instance.data[i]) then
      sum = sum + tonumber(instance.data[i])
    end
  end
  return sum
end

return Utils
