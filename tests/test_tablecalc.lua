local luaunit = require('luaunit')

-- Extending package.path to correctly set the directory for modules
package.path = package.path ..
    ";/home/user/code/lua/nvim-tablecalc/lua/?.lua;/home/user/code/lua/nvim-tablecalc/lua/?/init.lua"
local TableCalc = require('lua/nvim-tablecalc.init')

-- Defining the test suite
TestTableCalc = {}

-- Test 1: Check if get_instance creates a new instance with a Parsing object
function TestTableCalc:test_get_instance()
  local instance = TableCalc.get_instance()
  luaunit.assertNotNil(instance, "Instance should not be nil")
  luaunit.assertNotNil(instance.parsing, "Parsing object should be initialized")
end

-- Test 2: Check if new creates a TableCalc instance with all required fields
function TestTableCalc:test_new_instance()
  local instance = TableCalc.new()
  luaunit.assertNotNil(instance, "New instance should not be nil")
  luaunit.assertNotNil(instance.config, "Config object should be initialized")
  luaunit.assertNotNil(instance.utils, "Utils object should be initialized")
  luaunit.assertNotNil(instance.core, "Core object should be initialized")
  luaunit.assertFalse(instance.setup_done, "Setup flag should be false initially")
end

-- Test 3: Check if setup method correctly sets the setup_done flag to true
function TestTableCalc:test_setup()
  -- Mock the vim.api functions
  local mock_keymaps = {}

  _G.vim = {
    api = {
      nvim_set_keymap = function(mode, lhs, rhs, opts)
        table.insert(mock_keymaps, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
      end,
      nvim_create_user_command = function() end,
      nvim_create_autocmd = function() end
    }
  }

  -- Create a new instance of TableCalc
  local instance = TableCalc.new()
  luaunit.assertFalse(instance.setup_done, "Setup flag should be false initially")

  -- Call the setup method
  instance:setup()

  -- Assert that the setup was marked as done
  luaunit.assertTrue(instance.setup_done, "Setup flag should be true after setup")

  -- Check the first key mapping (normal mode)
  local normal_mapping = mock_keymaps[1]
  luaunit.assertEquals(normal_mapping.mode, "n", "First keymap should be for normal mode")
  luaunit.assertEquals(normal_mapping.lhs, "<leader>tc", "First keymap lhs should be <leader>tc")
  luaunit.assertEquals(
    normal_mapping.rhs,
    ':lua require("nvim-tablecalc").get_instance():run_normal()<CR>',
    "First keymap rhs should be correct"
  )
  luaunit.assertTrue(normal_mapping.opts.noremap, "First keymap should have noremap=true")
  luaunit.assertTrue(normal_mapping.opts.silent, "First keymap should have silent=true")
end

-- Test 4: Check if run_normal method correctly processes data in normal mode
function TestTableCalc:test_run_normal()
  local instance = TableCalc.new()
  -- Mocking the core and parsing methods
  ---@type Core
  instance.core = {
    read_buffer_normal = function() return "mock data" end,
    write_to_buffer = function() end,
    table_calc_instance = instance,
    config = instance.config,
    parsing = instance.parsing,
    utils = instance.utils,
  }
  ---@type Parsing
  instance.parsing = {
    parse_structured_table = function() return {} end,
    process_data = function() return "processed data" end,
    table_calc_instance = instance,
    config = instance.config,
    utils = instance.utils,
    rows = self.rows
  }

  -- Run the method
  instance:run_normal()
  -- We would check if the internal methods were called as expected in real tests
  -- For now, just verify that it runs without errors
  luaunit.assertTrue(true)
end

-- Test 6: Check if get_config returns the correct config object
function TestTableCalc:test_get_config()
  local instance = TableCalc.new()
  local config = instance:get_config()
  luaunit.assertNotNil(config, "Config object should be returned")
end

-- Test 9: Check if get_utils returns the correct utils object
function TestTableCalc:test_get_utils()
  local instance = TableCalc.get_instance()
  local utils = instance:get_utils()
  luaunit.assertNotNil(utils, "Utils object should be returned")
end
