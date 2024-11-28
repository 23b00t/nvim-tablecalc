local luaunit = require('luaunit')

local Config = require("nvim-tablecalc.config")

TestConfig = {}

-- Save original vim table to restore it after mocking it in tests
function TestConfig:setUp()
  self.original_vim = _G.vim
end

-- Helper function to mock _G.vim
local function mock_vim(filetype)
  _G.vim = {
    bo = { filetype = filetype }
  }
end

function TestConfig:test_new_instance()
  -- Act: Create a new instance of Config
  local instance = Config.new()

  -- Assert: Check default values
  luaunit.assertEquals(instance.delimiter, "|", "Default delimiter should be '|'")
  luaunit.assertEquals(instance.formula_begin, "{", "Default formula_begin should be '{'")
  luaunit.assertEquals(instance.formula_end, "}", "Default formula_end should be '}'")
  luaunit.assertEquals(instance.table_name_marker.org, "#", "Default table_name_marker for 'org' should be '#'")
  luaunit.assertEquals(instance.user_command, "", "user_command should be '' by default")
  luaunit.assertEquals(instance.commands.org, "normal! gggqG", "Default command for 'org' should be 'normal! gggqG'")
end

function TestConfig:test_get_command_with_user_command()
  -- Arrange: Mock vim.bo.filetype for test and set user command
  mock_vim("lua")
  local instance = Config.new()
  instance.user_command = "custom_command"

  -- Act: Get the command
  local command = instance:get_command()

  -- Assert: Ensure user command is returned
  luaunit.assertEquals(command, "custom_command", "get_command should return the user-defined command")
end

function TestConfig:test_get_command_without_user_command()
  -- Arrange: Mock vim.bo.filetype for test
  mock_vim("org")
  local instance = Config.new()

  -- Act: Get the command
  local command = instance:get_command()

  -- Assert: Ensure filetype-specific command is returned
  luaunit.assertEquals(command, "normal! gggqG", "get_command should return the filetype-specific command")
end

function TestConfig:test_get_command_with_unknown_filetype()
  -- Arrange: Mock vim.bo.filetype for test
  mock_vim("lua")
  local instance = Config.new()

  -- Act: Get the command
  local command = instance:get_command()

  -- Assert: Ensure an empty string is returned for unknown filetype
  luaunit.assertEquals(command, "", "get_command should return an empty string for unknown filetypes")
end

function TestConfig:test_autoformat_buffer()
  -- Arrange: Mock vim.bo.filetype for test
  mock_vim("org")
  local instance = Config.new()

  -- Act: Get the autoformat command
  local command = instance:get_command()

  -- Assert: Ensure the autoformat command is correct
  luaunit.assertEquals(command, "normal! gggqG", "autoformat_buffer should return the filetype-specific command")
end

function TestConfig:test_get_table_name_marker_with_known_filetype()
  -- Arrange: Mock vim.bo.filetype for test
  mock_vim("org")
  local instance = Config.new()

  -- Act: Get the table_name_marker
  local marker = instance:get_table_name_marker()

  -- Assert: Ensure the correct marker is returned
  luaunit.assertEquals(marker, "#", "get_table_name_marker should return the correct marker for known filetypes")
end

function TestConfig:test_get_table_name_marker_with_unknown_filetype()
  -- Arrange: Mock vim.bo.filetype for test
  mock_vim("unknown_filetype")
  local instance = Config.new()

  -- Act: Get the table_name_marker
  local marker = instance:get_table_name_marker()

  -- Assert: Ensure the default marker is returned
  luaunit.assertEquals(marker, "#", "get_table_name_marker should return the default marker for unknown filetypes")
end

function TestConfig:test_set_user_config()
  -- Arrange: Create a new Config instance and define a custom config
  local instance = Config.new()
  local custom_config = {
    delimiter = ",",
    formula_begin = "[",
    formula_end = "]",
    user_command = "custom_autoformat"
  }

  -- Act: Apply the custom configuration
  instance:set_user_config(custom_config)

  -- Assert: Check if the custom values were applied
  luaunit.assertEquals(instance.delimiter, ",", "delimiter should be updated to ','")
  luaunit.assertEquals(instance.formula_begin, "[", "formula_begin should be updated to '['")
  luaunit.assertEquals(instance.formula_end, "]", "formula_end should be updated to ']'")
  luaunit.assertEquals(instance.user_command, "custom_autoformat", "user_command should be updated to 'custom_autoformat'")
end

-- Restore the original _G.vim value after the test
function TestConfig:tearDown()
  _G.vim = self.original_vim
end
