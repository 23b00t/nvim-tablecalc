return {
  dir = "~/code/lua/nvim-tablecalc",   -- Lokaler Pfad zum Plugin
  lazy = true,                         -- Lazy Loading aktivieren
  keys = { "<leader>tc" },             -- Definiert das Keybinding, das das Plugin lädt
  config = function()
    -- Hier wird das Plugin geladen und Setup durchgeführt
    local TableCalc = require('nvim-tablecalc')
    local tablecalc_instance = TableCalc.get_instance()  -- Hole die Instanz
    tablecalc_instance:setup()  -- Setup-Funktion nach dem Laden aufrufen
  end
}
