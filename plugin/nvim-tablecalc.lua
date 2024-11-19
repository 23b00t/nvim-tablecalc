-- plugin/nvim-tablecalc.lua

if vim.g.loaded_nvim_tablecalc then
  return
end
vim.g.loaded_nvim_tablecalc = true

-- Function to initialize the TableCalc plugin lazily
local function lazy_load_tablecalc()
  local tablecalc = require("nvim-tablecalc").get_instance()
  tablecalc:setup()
  return tablecalc
end

-- INFO: Customizable filetypes in user config with:
-- vim.g.tablecalc_filetypes = { "org", "text", "markdown" }
-- Set a default value for tablecalc_filetypes if not already defined
vim.g.tablecalc_filetypes = vim.g.tablecalc_filetypes or { "org", "markdown" }

-- Autocommand to load the plugin lazily for the specified filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = vim.g.tablecalc_filetypes,  -- Use the user-defined or default filetypes
  callback = function()
    lazy_load_tablecalc()  -- Load the plugin when the filetype matches
  end
})
