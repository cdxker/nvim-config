local neogit = require("neogit")
local M = {}

neogit.setup {
  integrations = {
      telescope = true,
      diffview = true,
  }
}


function M.openFloating()
  neogit.open({ kind = "floating"})
end


vim.keymap.set("n", "<leader>gs", M.openFloating)
vim.keymap.set("n", "<C-g>", M.openFloating)

return M
