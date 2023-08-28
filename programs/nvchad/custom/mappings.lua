---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left"},
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right"},
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up"},
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down"},
  },
}

M.dap = {
  pulgin = true,
  n = {
    ["<leader>dp"] = {"<cmd> DapToggleBreakpoint <CR>"},
  }
}

M.dap_python = {
  pulgin = true,
  n = { 
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    },
  }
}

-- more keybinds!

return M
