return {
	{
		-- dir = "~/Projects/easy-projects.nvim", -- Use local development version
		-- name = "easy-projects",
		"ggyorfi/easy-projects.nvim",
		dependencies = {
			"ibhagwan/fzf-lua", -- We're using fzf-lua as our picker
		},
		lazy = false, -- Load immediately so commands are available
		keys = {
			{
				"<leader>fp",
				function()
					require("easy-projects").pick_project()
				end,
				desc = "Find Project",
			},
			{
				"<leader>pa",
				function()
					require("easy-projects").add_current_project()
				end,
				desc = "Add Current as Project",
			},
			-- Easy command keybindings
			{
				"<leader>qq",
				"<cmd>EasyQuit<cr>",
				desc = "Quit Neovim",
			},
			{
				"<leader>qc",
				"<cmd>EasyCloseAllSaved<cr>",
				desc = "Close All Saved Buffers",
			},
			{
				"<leader>qa",
				"<cmd>EasyAddProject<cr>",
				desc = "Add Current Project",
			},
			{
				"<leader>e",
				"<cmd>EasyToggleExplorer<cr>",
				desc = "Toggle Explorer",
			},
		},
		opts = {}, -- Use default configuration
	},
}
