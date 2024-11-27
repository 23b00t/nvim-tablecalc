-- lua/nvim-tablecalc/utils.lua

---@class Utils
---@field table_calc_instance TableCalc The instance of the TableCalc class
---@field config Config Configuration object for TableCalc
---@field rows table A table to store rows for processing
local Utils = {}

Utils.__index = Utils

--- Creates a new instance of Utils
---@return Utils A new instance of the Utils class
function Utils.new()
  local self = setmetatable({}, Utils)
  return self
end

--- Utility function to trim whitespace from strings
---@param str string The string to be trimmed
---@return string The trimmed string
function Utils.stripe(str)
  return (str or ""):match("^%s*(.-)%s*$")
end

--- Normalizes redundant operators in the expression (e.g., `--` becomes `+`, `-+` becomes `-`).
---@param expression string: The mathematical expression to normalize.
---@return string: The expression with normalized operators.
local function normalize_operators(expression)
  local previous
  repeat
    previous = expression
    expression = expression
        :gsub("([%%%^%+%*/%-])%s*([%%%^%+%*/%-])", function(op1, op2)
          if op1 == "-" and op2 == "-" then
            return "+" -- Replace `--` with `+`
          elseif op1 == "-" and op2 == "+" then
            return "-" -- Replace `-+` with `-`
          elseif op1 == "+" and op2 == "-" then
            return "-" -- Replace `+-` with `-`
          elseif op1 == op2 then
            return op1 -- Keep only one operator if they are identical
          else
            return op2 -- Keep the second operator in other cases
          end
        end)
  until expression == previous
  return expression
end

--- Simplifies a mathematical expression by normalizing operators and removing invalid characters.
-- This method handles redundant operators like `--` (converted to `+`), `-+` (converted to `-`),
-- and removes invalid or unnecessary characters from the expression.
---@param expression string: The mathematical expression to be simplified.
---@return string: The simplified mathematical expression.
function Utils:simplify_expression(expression)
  -- Remove invalid characters
  expression = expression:gsub("[^%.0-9%+%*%-%/%^%(%)]", "")

  -- Normalize redundant operators
  expression = normalize_operators(expression)

  -- Remove leading and trailing operators
  expression = expression
        :gsub("^%s*[%+%*%/%^]+", "")   -- Remove leading operators (not `-`) and preceding spaces
        :gsub("[%+%*%/%^%-]+%s*$", "") -- Remove trailing operators

  return expression
end


return Utils
