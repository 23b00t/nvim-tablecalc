-- lua/nvim-tablecalc/utils.lua
local M = {}
local config = require('nvim-tablecalc.config')

-- Extracts and evaluates formulas from a table and appends the result
function M.process_data(table_data)
  M.rows = table_data
  -- Iterate through all tables and their columns
  for _, table_name in pairs(table_data) do
    for column, values in pairs(table_name) do
      for i, cell in ipairs(values) do
        -- Detect if the cell contains a formula (starts with `=`)
        local match_expr = "^%" .. config.formula_begin .. "(.+)%" .. config.formula_end
        local formula = cell:match(match_expr)
        if formula then
          -- Evaluate the formula and append the result to the cell
          local result = M.evaluate_formula(formula)
          table_name[column][i] = config.formula_begin .. formula .. config.formula_end .. ": " .. result
        end
      end
    end
  end
  return table_data -- Return the updated table data
end

-- Evaluates a mathematical formula
function M.evaluate_formula(formula)
  -- Resolve references in the formula to their actual values
  -- print("Formula:", formula)
  local expression = M.resolve_expression(formula)
  -- print("Expression:", expression)

  if expression:match("sum") then
    return M.sum()
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
function M.resolve_expression(expression)
  -- Check for M.sum calls and resolve them
  -- expression = expression:gsub("sum%((%w+),%s*(%w+),?%s*(%w)%)", function(table_name, column_name, field_num)
  --   print(table_name)
  --   print(column_name)
  --   print(field_num)
  --   if not field_num then
  --     M.data = M.rows[table_name][column_name]
  --   elseif column_name == 'nil' then
  --     for _, column in pairs(M.rows[table_name]) do
  --       print(vim.inspect(column))
  --       table.insert(M.data, column[field_num]) -- Insert the value from the specific field into M.data
  --     end
  --   end
  --   -- return "M.sum"
  -- end)

  -- Replace references of the form Table.Column.Row with actual values
  -- TODO: If numbers put just return theme
  return expression:gsub("(%w+).(%w+).(%d+)", function(table_name, column_name, row_index)
    local table_data = M.rows[table_name] -- Get the table data by name
    if table_data and table_data[column_name] then
      local row_value = table_data[column_name][tonumber(row_index)]
      return tostring(row_value) -- Convert the value to a string for Lua expressions
    else
      error("Invalid reference: " )
    end
  end)
end

-- Writes the modified table data back to the buffer
function M.write_to_buffer(table_data)
  -- Iterate over all tables and their columns
  for _, columns in pairs(table_data) do
    for _, rows in pairs(columns) do
      -- Process each cell to append results to formulas
      for _, cell_content in pairs(rows) do
        local formula, result = cell_content:match("^(%" ..
          config.formula_begin .. ".-%" .. config.formula_end .. "): (.+)$")
        if formula and result then
          -- Search the buffer for the formula and append the result
          for line_number = 1, vim.api.nvim_buf_line_count(0) do
            local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local col_start, col_end = line_content:find(formula, 1, true)
            if col_start then
              -- Update the line by appending the result to the formula
              local updated_line = line_content:sub(1, col_end) .. ": " .. result
              vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { updated_line })
              break
            end
          end
        end
      end
    end
  end

  -- Format the buffer (e.g., re-align text)
  vim.cmd(config.get_command())
end

-- Utility function to trim whitespace from strings
function M.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

-- Sum columns
function M.sum()
  local sum = 0

  for i = 1, #M.data do
    if tonumber(M.data[i]) then
      sum = sum + tonumber(M.data[i])
    end
  end
  return sum
end

return M
