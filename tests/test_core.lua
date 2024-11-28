local luaunit = require('luaunit')

local TableCalc = _G.TableCalc

local Core = require("nvim-tablecalc.core")

TestCore = {}

function TestCore:setUp()
  self.original_vim = _G.vim
  _G.vim = {
    bo = { filetype = "lua" },
    api = {
      nvim_buf_get_lines = function()
        return { "line 1", "line 2" }
      end,
      nvim_buf_set_lines = function()
        _G.vim.api.nvim_buf_set_lines_called = true -- Flag for checking if nvim_buf_set_lines is called
      end,
      nvim_put = function()
        _G.vim.api.nvim_put_called = true -- Flag for checking if nvim_put is called
      end,
      nvim_win_get_cursor = function() end,
      nvim_win_set_cursor = function() end,
    },

    cmd = function() end,

    pesc = function(input)
      return input
    end,


    -- Mock for vim.split
    split = function(str, delimiter)
      -- Mimic splitting the string by delimiter
      local result = {}
      if delimiter == '\n' then
        for line in str:gmatch("([^\n]+)") do
          table.insert(result, line)
        end
      end
      return result
    end,
  }
end

function TestCore:test_new_instance()
  local table_calc_instance = TableCalc.get_instance()
  local core_instance = Core.new(table_calc_instance)

  luaunit.assertEquals(core_instance.table_calc_instance, table_calc_instance, "TableCalc instance should be set")
  luaunit.assertEquals(core_instance.config, table_calc_instance.config, "Config should be assigned from TableCalc")
  luaunit.assertEquals(core_instance.utils, table_calc_instance.utils, "Utils should be assigned from TableCalc")
  luaunit.assertEquals(core_instance.parsing, table_calc_instance.parsing, "Parsing should be assigned from TableCalc")
end

function TestCore:test_read_buffer_normal()
  local core_instance = Core.new(TableCalc.get_instance())
  local result = core_instance:read_buffer_normal()
  luaunit.assertEquals(result, "line 1\nline 2", "read_buffer_normal should return the full buffer content")
end

function TestCore:test_write_to_buffer()
  local core_instance = Core.new(TableCalc.get_instance())
  core_instance.buffer = "some buffer content"
  core_instance:write_to_buffer({ "{sum(S, nil, 2)}: 28" })

  luaunit.assertTrue(vim.api.nvim_buf_set_lines_called, "vim.api.nvim_buf_set_lines should be called")
end

function TestCore:test_insert_table()
  local core_instance = Core.new(TableCalc.get_instance())
  core_instance:insert_table("3", "5", "")

  luaunit.assertTrue(vim.api.nvim_put_called, "vim.api.nvim_put should be called to insert the table")
end

-- Restore the original _G.vim value after the test
function TestCore:tearDown()
  _G.vim = self.original_vim
end
