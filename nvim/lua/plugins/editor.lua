return {
    -- Treesitter Syntax Highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",

        opts = {
            ensured_installed = {
                "bash",
                "c",
                "cmake",
                "comment",
                "cpp",
                "diff",
                "dockerfile",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "go",
                "lua",
                "make",
                "python",
                "toml",
                "vim",
                "vimdoc",
                "query",
                "yaml",
            },
            sync_install = false,
            auto_install = false,
            highlight = { enable = true, additional_vim_regex_highlighting = false, },
            indent = { enable = true },
        },

        config = function(opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    -- Fuzzy Directory Finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", noremap = true, silent = true, desc = "Find Files" },
            { "<leader>gg", "<cmd>Telescope live_grep<CR>", noremap = true, silent = true},
            { "<leader>bb", "<cmd>Telescope buffers<CR>", noremap = true, silent = true},
            { "<leader>hff", "<cmd>Telescope find_files hidden=true<CR>", noremap = true, silent = true},
        },
        config = true,
    },
}
