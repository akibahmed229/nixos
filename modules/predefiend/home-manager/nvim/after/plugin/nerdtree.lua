-- Define a function to open NERDTree
local function openNERDTree()
    vim.cmd(":NERDTree")
end

-- Bind a key to open NERDTree
vim.api.nvim_set_keymap('n', '<C-t>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
