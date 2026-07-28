vim.api.nvim_create_augroup("augroup", {clear = true})

-- Strip trailing whitespaces on save.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "augroup",
    pattern = "*",
    command = "keeppatterns %s/\\s\\+$//e"
})

-- Remap netrw refresh
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        pcall(vim.api.nvim_buf_del_keymap, 0, 'n', '<C-L>')
    end,
})

