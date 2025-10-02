return {
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		config = function()
			local neoscroll = require("neoscroll")

			neoscroll.setup({
				mappings = {}, -- Disable default mappings, we'll set custom ones
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
				easing_function = nil,
				pre_hook = nil,
				post_hook = nil,
				performance_mode = false,
			})

			-- Custom mappings with 200ms duration
			local keymap = {
				["<C-u>"] = function()
					neoscroll.ctrl_u({ duration = 200 })
				end,
				["<C-d>"] = function()
					neoscroll.ctrl_d({ duration = 200 })
				end,
				["<C-b>"] = function()
					neoscroll.ctrl_b({ duration = 200 })
				end,
				["<C-f>"] = function()
					neoscroll.ctrl_f({ duration = 200 })
				end,
				["<C-y>"] = function()
					neoscroll.scroll(-0.1, { move_cursor = false, duration = 200 })
				end,
				["<C-e>"] = function()
					neoscroll.scroll(0.1, { move_cursor = false, duration = 200 })
				end,
				["zt"] = function()
					neoscroll.zt({ half_win_duration = 200 })
				end,
				["zz"] = function()
					neoscroll.zz({ half_win_duration = 200 })
				end,
				["zb"] = function()
					neoscroll.zb({ half_win_duration = 200 })
				end,
			}

			local modes = { "n", "v", "x" }
			for key, func in pairs(keymap) do
				vim.keymap.set(modes, key, func)
			end
		end,
	},
}
