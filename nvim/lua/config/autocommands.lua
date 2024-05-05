vim.api.nvim_create_augroup("augroup", {clear = true})

-- Strip trailing whitespaces on save.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "augroup",
    pattern = "*",
    command = "keeppatterns %s/\\s\\+$//e"
})

