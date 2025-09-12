-- ~/.config/nvim/lua/plugins/mini-diff.lua
return {
	{
		"echasnovski/mini.diff",
		version = false,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Make sure the gutter is visible
			vim.opt.signcolumn = "yes"

			require("mini.diff").setup({
				view = {
					style = "sign", -- VS Code-like gutter marks
				},
				signs = {
					add = "│",
					change = "│",
					delete = "_",
				},
				-- If you also use gitsigns, keep mini.diff at lower priority
				-- so Git signs win when both exist on the same line.
				options = { signs = { priority = 1 } },
			})
		end,
	},
}
