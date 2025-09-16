return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Optional: hide builtin cmdline (uncomment if you only want the fake one)
			-- vim.o.cmdheight = 0

			----------------------------------------------------------------
			-- Helpers to read theme colors from lualine's groups per mode
			----------------------------------------------------------------
			local function mode_slug()
				local m = vim.fn.mode(1)
				if m:find("^i") then
					return "insert"
				end
				if m:find("^[vV\22]") then
					return "visual"
				end -- \22 = Ctrl-V
				if m:find("^R") then
					return "replace"
				end
				if m:find("^c") then
					return "command"
				end
				if m:find("^[sS\19]") then
					return "visual"
				end -- select -> visual palette
				if m:find("^t") then
					return "terminal"
				end
				return "normal"
			end

			local function get_hl(name)
				-- nvim 0.10+: returns ints; follow links if needed
				if vim.api.nvim_get_hl then
					local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
					if ok and hl and (hl.fg or hl.bg) then
						return hl
					end
					ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = true })
					if ok and hl then
						if hl.link then
							local ok2, r = pcall(vim.api.nvim_get_hl, 0, { name = hl.link, link = false })
							if ok2 and r then
								return r
							end
						end
						return hl
					end
				end
				-- nvim 0.9 fallback
				if vim.api.nvim_get_hl_by_name then
					local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
					if ok and hl then
						return hl
					end
				end
				return {}
			end

			local function to_hex(n)
				return type(n) == "number" and string.format("#%06x", n) or n
			end

			-- Compute component colors from the theme's lualine groups
			local function current_section_colors()
				local grp = "lualine_c_" .. mode_slug()
				local hl = get_hl(grp)
				local fg = to_hex(hl.fg)
				local bg = to_hex(hl.bg)
				-- Fallbacks
				if not (fg or bg) then
					hl = get_hl("StatusLine")
					fg = to_hex(hl.fg)
					bg = to_hex(hl.bg)
				end
				return { fg = fg, bg = bg }
			end

			-- Keep a cached caret HL that inverts the component's colors
			local function update_caret_hl()
				-- Cursor with black text on white background
				vim.api.nvim_set_hl(0, "LualineCmdCursor", {
					fg = "#000000", -- black text
					bg = "#ffffff", -- white background
				})
				-- Also create highlight for component text
				vim.api.nvim_set_hl(0, "LualineCmdText", {
					fg = "#fab387", -- orange text
					bg = "#181825", -- dark background
				})
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
			-- Fake cmdline component (single-cell caret, no width changes)
			----------------------------------------------------------------
			local function cmdline_component()
				local t = vim.fn.getcmdtype()
				if t == "" then
					return ""
				end

				local prefix = ({ [":"] = ":", ["/"] = "/", ["?"] = "?", ["="] = "=", ["@"] = "@" })[t] or t
				local s = vim.fn.getcmdline()
				local pos = vim.fn.getcmdpos() -- 1-based

				if pos < 1 then
					pos = 1
				end
				if pos > #s + 1 then
					pos = #s + 1
				end

				local before = s:sub(1, pos - 1)
				local head = s:sub(pos, pos)

				-- At EOL: exactly one highlighted space
				if head == "" then
					return "%#LualineCmdText#" .. prefix .. before .. "%#LualineCmdCursor# %*"
				end

				local tail = s:sub(pos + 1)
				-- Use explicit highlight groups to maintain colors
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
							-- Color the WHOLE cmdline component with the theme section colors of the *current* mode
							color = function()
								-- TEMP: Force orange to see if component coloring works
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
							color = { fg = "#f38ba8" }, -- Red color for the recording indicator
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
			-- Keep lualine updating while typing and when mode/colors change
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
					update_caret_hl()
					refresh()
				end,
			})

			-- Extra responsiveness with ext_cmdline (safe no-op if unsupported)
			-- Skip in Neovide to avoid compatibility issues
			if vim.ui_attach and not vim.g.neovide then
				pcall(
					vim.ui_attach,
					vim.api.nvim_create_namespace("lualine_cmdline"),
					{ ext_cmdline = true },
					function(ev)
						if ev == "cmdline_show" or ev == "cmdline_pos" or ev == "cmdline_hide" then
							update_caret_hl()
							refresh()
						end
						return true
					end
				)
			end
		end,
	},
}
