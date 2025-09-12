return {
	-- Mason for LSP management
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Formatters & Linters
					"prettier",
					"eslint_d",
					"black",
					"isort",
					"stylua",
					"gofumpt",
				},
			})
		end,
	},

	-- Mason LSP config bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				-- Use LSP server names, not package names (ts_ls removed - using typescript-tools)
				"html", -- HTML
				"cssls", -- CSS
				"tailwindcss", -- Tailwind
				"jsonls", -- JSON
				"yamlls", -- YAML
				"pyright", -- Python
				"gopls", -- Go
				-- "lua_ls",          -- Lua (manual setup below)
				"rust_analyzer", -- Rust
			},
			automatic_installation = true,
			handlers = {
				-- Default handler for all servers
				function(server_name)
					-- Skip ts_ls since we use typescript-tools
					if server_name == "ts_ls" then
						return
					end
					require("lspconfig")[server_name].setup({})
				end,
			},
		},
	},

	-- TypeScript enhanced features
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			settings = {
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"ibhagwan/fzf-lua",
		},
		config = function()
			-- Manual lua_ls setup (since removed from mason-lspconfig)
			require("lspconfig").lua_ls.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
							},
						},
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim", "Snacks" },
							disable = { "duplicate-set-field" },
						},
					},
				},
			})

			-- Global diagnostics config
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
			})

			-- Improve LSP UI (Neovim 0.11+ method)
			local _signature_help = vim.lsp.buf.signature_help
			vim.lsp.buf.signature_help = function(opts)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				return _signature_help(opts)
			end

			local _hover = vim.lsp.buf.hover
			vim.lsp.buf.hover = function(opts)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				return _hover(opts)
			end

			-- Configure LSP floating window colors to match theme
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					-- Get current theme colors
					local normal_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg")
					local comment_fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Comment")), "fg")

					-- Set floating window colors
					if normal_bg ~= "" then
						vim.api.nvim_set_hl(0, "NormalFloat", { bg = normal_bg })
						vim.api.nvim_set_hl(0, "FloatBorder", { bg = normal_bg, fg = comment_fg })
					end
				end,
			})

			-- Apply immediately for current theme
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("ColorScheme", {})
			end)

			-- Set LSP keymaps when server attaches (LazyVim style)
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Navigation keymaps (use fzf-lua if available, fallback to LSP)
					local fzf_available = pcall(require, "fzf-lua")
					if fzf_available then
						map("gd", require("fzf-lua").lsp_definitions, "Goto Definition")
						map("gr", require("fzf-lua").lsp_references, "Goto References")
						map("gI", require("fzf-lua").lsp_implementations, "Goto Implementation")
						map("gy", require("fzf-lua").lsp_typedefs, "Type Definition")
					else
						map("gd", vim.lsp.buf.definition, "Goto Definition")
						map("gr", vim.lsp.buf.references, "Goto References")
						map("gI", vim.lsp.buf.implementation, "Goto Implementation")
						map("gy", vim.lsp.buf.type_definition, "Type Definition")
					end

					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gK", vim.lsp.buf.signature_help, "Signature Help")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("<leader>cr", vim.lsp.buf.rename, "Rename")
				end,
			})

			-- LazyVim LSP Keymaps Cheatsheet (uses fzf-lua when available):
			--
			-- Navigation:
			--   gd          - Goto Definition
			--   gr          - Goto References
			--   gI          - Goto Implementation
			--   gy          - Goto Type Definition
			--   gD          - Goto Declaration
			--
			-- Documentation:
			--   K           - Hover Documentation
			--   gK          - Signature Help
			--   <c-k>       - Signature Help (insert mode)
			--
			-- Code Actions:
			--   <leader>ca  - Code Action
			--   <leader>cc  - Run Codelens
			--   <leader>cC  - Refresh & Display Codelens
			--   <leader>cR  - Rename File
			--
			-- Refactoring:
			--   <leader>cr  - Rename Symbol
			--   <leader>cA  - Source Action
			--
			-- Diagnostics:
			--   <leader>cd  - Line Diagnostics
			--   ]d          - Next Diagnostic
			--   [d          - Prev Diagnostic
			--   ]e          - Next Error
			--   [e          - Prev Error
			--   ]w          - Next Warning
			--   [w          - Prev Warning
		end,
	},
}
