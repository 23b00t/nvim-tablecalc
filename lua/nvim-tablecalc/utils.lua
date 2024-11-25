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

--- Sums the values in the data table
---@return number The sum of the values
function Utils:sum(data)
  local sum = 0
  -- Iterate through the data and sum the numeric values
  for i = 1, #data do
    if tonumber(data[i]) then
      sum = sum + tonumber(data[i])
    end
  end
  return sum
end

return Utils
