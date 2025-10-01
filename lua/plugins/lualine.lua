return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			----------------------------------------------------------------
			-- Highlights for the cmdline component
			----------------------------------------------------------------
			local function update_caret_hl()
				vim.api.nvim_set_hl(0, "LualineCmdCursor", { fg = "#000000", bg = "#ffffff" })
				vim.api.nvim_set_hl(0, "LualineCmdText", { fg = "#fab387", bg = "#181825" })
			end

			update_caret_hl()
			vim.api.nvim_create_autocmd({ "ModeChanged", "ColorScheme", "WinEnter", "BufEnter" }, {
				callback = update_caret_hl,
			})

			----------------------------------------------------------------
			-- Macro recording component
			----------------------------------------------------------------
			local function macro_recording()
				local reg = vim.fn.reg_recording()
				if reg == "" then
					return ""
				end
				return "● @" .. reg
			end

			----------------------------------------------------------------
			-- Cmdline component with % escaping
			----------------------------------------------------------------
			local function esc_percent(s)
				return (s or ""):gsub("%%", "%%%%")
			end

			local function cmdline_component()
				local t = vim.fn.getcmdtype()
				if t == "" then
					return ""
				end

				local prefix = ({ [":"] = ":", ["/"] = "/", ["?"] = "?", ["="] = "=", ["@"] = "@" })[t] or t
				local s = vim.fn.getcmdline()
				local pos = vim.fn.getcmdpos()

				if pos < 1 then
					pos = 1
				end
				if pos > #s + 1 then
					pos = #s + 1
				end

				local before = esc_percent(s:sub(1, pos - 1))
				local head = esc_percent(s:sub(pos, pos))

				if head == "" then
					return "%#LualineCmdText#" .. prefix .. before .. "%#LualineCmdCursor# %*"
				end

				local tail = esc_percent(s:sub(pos + 1))
				return "%#LualineCmdText#"
					.. prefix
					.. before
					.. "%#LualineCmdCursor#"
					.. head
					.. "%#LualineCmdText#"
					.. tail
					.. "%*"
			end

			----------------------------------------------------------------
			-- Lualine setup
			----------------------------------------------------------------
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						"filename",
						vim.g.neovide and {} or {
							cmdline_component,
							cond = function()
								return vim.fn.getcmdtype() ~= ""
							end,
							padding = { left = 0, right = 0 },
							separator = "",
							color = function()
								return { fg = "#fab387", bg = "#181825" }
							end,
						},
					},
					lualine_x = {
						{
							macro_recording,
							cond = function()
								return vim.fn.reg_recording() ~= ""
							end,
							color = { fg = "#f38ba8" },
						},
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})

			----------------------------------------------------------------
			-- Refresh on cmdline changes
			----------------------------------------------------------------
			local function refresh()
				pcall(require("lualine").refresh, { place = { "statusline" } })
			end

			vim.api.nvim_create_autocmd({
				"CmdlineEnter",
				"CmdlineChanged",
				"CmdlineLeave",
				"CmdwinEnter",
				"CmdwinLeave",
				"ModeChanged",
				"ColorScheme",
			}, {
				callback = function()
					vim.schedule(function()
						update_caret_hl()
						refresh()
					end)
				end,
			})

			-- Use ext_cmdline to hide the native cmdline (skip in Neovide)
			if vim.ui_attach and not vim.g.neovide then
				pcall(function()
					local ns = vim.api.nvim_create_namespace("lualine_cmdline")
					vim.ui_attach(ns, { ext_cmdline = true }, function()
						return true
					end)
				end)
			end

			----------------------------------------------------------------
			-- Workaround: Disable inccommand during :s/ to allow statusline updates
			----------------------------------------------------------------
			local saved_icm = nil
			vim.api.nvim_create_autocmd("CmdlineChanged", {
				callback = function()
					if vim.fn.getcmdtype() == ":" then
						local s = vim.fn.getcmdline()
						-- Detect substitute commands early: as soon as ":s" or ":%s" is typed
						local is_substitute = s:match("^%%?s") -- %s or s
							or s:match("^'[<>],?'[<>]s") -- '<,'>s
							or s:match("^%d+,%d+s") -- 1,10s
							or s:match("^%.,%$s") -- .,$s

						if is_substitute then
							if saved_icm == nil then
								saved_icm = vim.o.inccommand
								vim.o.inccommand = "" -- disable live preview for statusline updates
							end
						else
							-- Not a substitute command, restore inccommand
							if saved_icm ~= nil then
								vim.o.inccommand = saved_icm
								saved_icm = nil
							end
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("CmdlineLeave", {
				callback = function()
					-- Always restore on leave
					if saved_icm ~= nil then
						vim.o.inccommand = saved_icm
						saved_icm = nil
					end
				end,
			})
		end,
	},
}
