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
      -- nvim_create_user_command = function() end -- for later use
    }
  }

  -- Create a new instance of TableCalc
  local instance = TableCalc.new()
  luaunit.assertFalse(instance.setup_done, "Setup flag should be false initially")

  -- Call the setup method
  instance:setup()

  -- Assert that the setup was marked as done
  luaunit.assertTrue(instance.setup_done, "Setup flag should be true after setup")

  -- Validate key mappings
  luaunit.assertEquals(#mock_keymaps, 2, "Two key mappings should have been set")

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

  -- Check the second key mapping (visual mode)
  local visual_mapping = mock_keymaps[2]
  luaunit.assertEquals(visual_mapping.mode, "v", "Second keymap should be for visual mode")
  luaunit.assertEquals(visual_mapping.lhs, "<leader>tc", "Second keymap lhs should be <leader>tc")
  luaunit.assertEquals(
    visual_mapping.rhs,
    ':lua require("nvim-tablecalc").get_instance():run_visual()<CR>',
    "Second keymap rhs should be correct"
  )
  luaunit.assertTrue(visual_mapping.opts.noremap, "Second keymap should have noremap=true")
  luaunit.assertTrue(visual_mapping.opts.silent, "Second keymap should have silent=true")
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
  }
  instance.parsing = {
    parse_structured_table = function() return {} end,
    table_calc_instance = instance,
    config = instance.config,
    utils = instance.utils,
    rows = self.rows
  }
  instance.utils = {
    process_data = function() return "processed data" end,
    table_calc_instance = instance,
    config = instance.config,
    rows = self.rows
  }

  -- Run the method
  instance:run_normal()
  -- We would check if the internal methods were called as expected in real tests
  -- For now, just verify that it runs without errors
  luaunit.assertTrue(true)
end

-- Test 5: Check if run_visual method correctly processes data in visual mode
function TestTableCalc:test_run_visual()
  local instance = TableCalc.new()

  -- Mocking the core and parsing methods
  instance.core = {
    read_buffer_visual = function() return "mock visual data" end,
    write_to_buffer = function() end,
    table_calc_instance = instance,
    config = instance.config,
  }
  instance.parsing = {
    parse_structured_table = function() return {} end,
    table_calc_instance = instance,
    config = instance.config,
    utils = instance.utils,
    rows = self.rows
  }
  instance.utils = {
    process_data = function() return "processed data" end,
    table_calc_instance = instance,
    config = instance.config,
    rows = self.rows
  }

  -- Run the method
  instance:run_visual()
  -- Similar to `run_normal`, this would be verified by checking function calls
  luaunit.assertTrue(true)
end

-- Test 6: Check if get_config returns the correct config object
function TestTableCalc:test_get_config()
  local instance = TableCalc.new()
  local config = instance:get_config()
  luaunit.assertNotNil(config, "Config object should be returned")
end

-- Test 7: Check if get_parsing returns the correct parsing object
function TestTableCalc:test_get_parsing()
  local instance = TableCalc.get_instance()
  local parsing = instance:get_parsing()
  luaunit.assertNotNil(parsing, "Parsing object should be returned")
end

-- Test 8: Check if get_core returns the correct core object
function TestTableCalc:test_get_core()
  local instance = TableCalc.get_instance()
  local core = instance:get_core()
  luaunit.assertNotNil(core, "Core object should be returned")
end

-- Test 9: Check if get_utils returns the correct utils object
function TestTableCalc:test_get_utils()
  local instance = TableCalc.get_instance()
  local utils = instance:get_utils()
  luaunit.assertNotNil(utils, "Utils object should be returned")
end
