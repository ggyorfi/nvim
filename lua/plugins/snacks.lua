return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- LazyVim default snacks features with explanations
			bigfile = { enabled = false }, -- Disable features on big files for performance
			notifier = {
				enabled = true, -- Enable for debugging
				timeout = 2000,
			}, -- Better vim.notify() with nice animations
			messages = { enabled = true }, -- Handle :messages
			quickfile = { enabled = true }, -- Fast file operations
			statuscolumn = { enabled = false }, -- Enhanced line number column with git signs
			words = { enabled = true }, -- Highlight other instances of word under cursor
			explorer = { enabled = true }, -- File explorer with tree view and operations
			input = { enabled = true }, -- Enhanced vim.ui.input with proper sizing
			terminal = {
				win = {
					position = "bottom",
					height = 0.3, -- 30% of screen height
					border = "single",
				},
			},
			dashboard = { enabled = false }, -- Disable dashboard that might add footer
			indent = { enabled = true }, -- Disable indent guides that might affect statusline
			picker = {
				ui_select = true, -- Enable Snacks picker for vim.ui.select
				sources = {
					explorer = {
						hidden = true, -- Show hidden files
						ignored = true, -- Show ignored files
						exclude = {
							".DS_Store",
							".git",
							".vscode",
							".idea",
							"*.pyc",
							"__pycache__",
							".pytest_cache",
							".mypy_cache",
							".cache",
						},
						-- Custom layout to remove search box (since we use fzf-lua for file finding)
						layout = {
							preview = "main",
							layout = {
								backdrop = false,
								width = 30, -- Explorer width
								min_width = 30,
								height = 0, -- Full height
								position = "left", -- Left sidebar
								border = "none",
								box = "vertical",
								-- Only show file list (no input/search box)
								{ win = "list", border = "none" },
							},
						},
					},
				},
			},
			styles = {
				notification = {
					wo = { wrap = true }, -- Allow notifications to wrap
				},
			},
		},
		keys = {
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification History",
			},
		},
	},
}
