-- plugin/nvim-tablecalc.lua

if vim.g.loaded_nvim_tablecalc then
  return
end
vim.g.loaded_nvim_tablecalc = true

local function lazy_load_tablecalc()
  local tablecalc = require("nvim-tablecalc").get_instance()
  tablecalc:setup()
  return tablecalc
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "org", "md" },
  callback = function()
    lazy_load_tablecalc()
  end
})
