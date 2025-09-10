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
opt.laststatus = 3
opt.cmdheight = 0

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard by default

