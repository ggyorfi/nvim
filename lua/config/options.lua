-- Options are automatically loaded before lazy.nvim startup
-- We'll add options step by step as needed

local opt = vim.opt

-- Essential settings
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.mouse = "a" -- Enable mouse support

-- Indentation
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically

-- Search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

-- UI cleanup
opt.showmode = false
opt.laststatus = 2 -- Force statusline to always show
opt.cmdheight = 0 -- Hide native cmdline (using lualine fake cmdline instead)

-- Enable live preview by default (dynamically disabled for :s/ by lualine config)
opt.inccommand = "split"

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard by default

-- Enable highlighting for unsaved changes
vim.opt.signcolumn = "yes"

-- Neovide settings (only apply if running in Neovide)
if vim.g.neovide then
	vim.g.neovide_cursor_animation_length = 0 -- Disable cursor animation
	vim.g.neovide_cursor_trail_size = 0 -- Disable cursor trail
	vim.g.neovide_scroll_animation_length = 0 -- Disable scroll animation
	vim.g.neovide_position_animation_length = 0 -- Disable window position animation

	-- Fix statusline visibility in Neovide
	-- vim.opt.laststatus = 2 -- Force statusline to always show

	-- -- Force lualine refresh after startup to fix rendering issues
	-- vim.defer_fn(function()
	-- 	if pcall(require, "lualine") then
	-- 		require("lualine").refresh()
	-- 	end
	-- end, 200)

	-- 	-- Handle window resize events to fix statusline on maximize/restore
	-- 	vim.api.nvim_create_autocmd("VimResized", {
	-- 		callback = function()
	-- 			if pcall(require, "lualine") then
	-- 				require("lualine").refresh()
	-- 			end
	-- 		end,
	-- 	})
end
