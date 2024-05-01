return {
    -- Status Iconds
    { "nvim-tree/nvim-web-devicons", },

    -- Color Theme
    {
        "marko-cerovac/material.nvim",
        opts = {
            contrast = {
                terminal = true, -- Enable contrast for the built-in terminal
                sidebars = true, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
                floating_windows = true, -- Enable contrast for floating windows
                cursor_line = false, -- Enable darker background for the cursor line
                lsp_virtual_text = false, -- Enable contrasted background for lsp virtual text
                non_current_windows = false, -- Enable contrasted background for non-current windows
                filetypes = {  -- Specify which filetypes get the contrasted (darker) background
                    "c",
                    "cpp",
                }, 
            },
        },

        config = function()
            vim.g.material_style = "oceanic"
            require('material').setup(opts)
            vim.cmd "colorscheme material"
        end,
    },

    -- Status Bar
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = true,
    },
}
