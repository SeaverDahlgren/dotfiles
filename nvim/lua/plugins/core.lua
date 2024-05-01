return {
    -- C-{hjkl} split navigation for nvim and tmux
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
        end,
    },
}
