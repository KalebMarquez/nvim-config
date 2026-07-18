-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd.colorscheme([[tokyonight-night]])
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter").install({ "lua", "rust", "javascript", "python", "nix" })

				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "lua", "rust", "javascript", "python", "nix" },
					callback = function()
						vim.treesitter.start()
					end,
				})
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			config = function()
				require("nvim-treesitter-textobjects").setup({})
			end,
		},
		{
			"neovim/nvim-lspconfig",
			config = function()
				vim.lsp.enable("clangd")
				vim.lsp.enable("lua_ls")
				vim.lsp.enable("rust_analyzer")
			end,
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			dependencies = { "rafamadriz/friendly-snippets" },
			opts = {
				keymap = { preset = "default" },
				appearance = { nerd_font_variant = "mono" },
				sources = {
					default = { "lazydev", "lsp", "path", "snippets", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							score_offset = 100,
						},
					},
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{
			"nvim-tree/nvim-tree.lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("nvim-tree").setup()
			end,
		},
		{
			"akinsho/bufferline.nvim",
			version = "*",
			dependencies = "nvim-tree/nvim-web-devicons",
			config = function()
				require("bufferline").setup({
					options = {
						separator_style = "slope",
						indicator = {
							style = "underline",
						},
						diagnostics = "nvim_lsp",
						diagnostics_indicator = function(count, level)
							local icon = level:match("error") and "E" or "W"
							return " " .. icon .. count
						end,
					},
				})
			end,
		},
        {
            "nvim-telescope/telescope.nvim",
            version = "*",
            dependencies = {
                "nvim-lua/plenary.nvim",
                {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
            },
            config = function()
                require("telescope").setup({})
                require("telescope").load_extension("fzf")
            end,
        },
	},
})
