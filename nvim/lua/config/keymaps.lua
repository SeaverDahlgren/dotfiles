opts = {noremap = true}

-- Set space as leader
vim.g.mapleader = ' '

-- Toggle netrw
vim.keymap.set('n', '<leader>pv', ':Vexplore<CR>', opts)

-- Move between buffers
vim.keymap.set('n', '<leader><leader>', ':b#<CR>', opts)

-- Create splits
vim.keymap.set('n', '<leader>v', ':vsplit<CR>', opts)
vim.keymap.set('n', '<leader>x', ':split<CR>', opts)

-- Move around splits using Ctrl + {h,j,k,l}
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Map jj to Escape
vim.keymap.set('i', 'jj', '<Esc>', opts)

-- Zoom in on Window
vim.keymap.set('n', '<leader>z', '<C-w>|<C-w>_', opt)
vim.keymap.set('n', '<leader>=', '<C-w>=', opts)

-- Toggle Default clipboard
function ToggleClipboard()
    if vim.tbl_contains(vim.opt.clipboard:get(), "unnamedplus") then
        vim.opt.clipboard = ""
    else
        vim.opt.clipboard = "unnamedplus"
    end
    vim.print(vim.opt.clipboard:get())
end

vim.api.nvim_set_keymap('n', '<leader>mm', ':lua ToggleClipboard()<CR>', opts)
