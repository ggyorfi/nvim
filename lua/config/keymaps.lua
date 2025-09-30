-- Keymaps are automatically loaded on the VeryLazy event
-- We'll add keymaps step by step as needed

local map = vim.keymap.set

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Pane navigation (works in all modes)
map({ "n", "i", "v" }, "<C-h>", "<C-w>h", { desc = "Move to left pane" })
map({ "n", "i", "v" }, "<C-j>", "<C-w>j", { desc = "Move to bottom pane" })
map({ "n", "i", "v" }, "<C-k>", "<C-w>k", { desc = "Move to top pane" })
map({ "n", "i", "v" }, "<C-l>", "<C-w>l", { desc = "Move to right pane" })

-- Terminal mode navigation (needs different syntax)
map("t", "<C-h>", "<c-\\><c-n><c-w>h", { desc = "Move to left pane" })
map("t", "<C-j>", "<c-\\><c-n><c-w>j", { desc = "Move to bottom pane" })
map("t", "<C-k>", "<c-\\><c-n><c-w>k", { desc = "Move to top pane" })
map("t", "<C-l>", "<c-\\><c-n><c-w>l", { desc = "Move to right pane" })

-- Terminal toggle (with tmux)
map("n", "<C-t>", function()
	-- Check if tmux is available
	if vim.fn.executable("tmux") == 1 then
		Snacks.terminal("tmux new-session -A -s 0")
	else
		Snacks.terminal()
	end
end, { desc = "Toggle terminal (tmux)" })
map("t", "<C-t>", "<c-\\><c-n><cmd>close<cr>", { desc = "Toggle terminal" })

-- Terminal keymaps
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })

-- Command-line keymaps - make Ctrl+P/N behave like Up/Down (prefix search)
map("c", "<C-p>", "<Up>", { desc = "Previous command (prefix search)" })
map("c", "<C-n>", "<Down>", { desc = "Next command (prefix search)" })

-- Buffer management
map("n", "<leader>bc", "<cmd>EasyCloseBuffer<cr>", { desc = "Close buffer" })
map("n", "<leader>bC", "<cmd>EasyCloseBuffer!<cr>", { desc = "Close buffer (force)" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin buffer" })
map("n", "<leader>b<", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })
map("n", "<leader>b>", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
map("n", "<leader>ba", "<cmd>EasyCloseAllSaved<cr>", { desc = "Close all saved buffers" })

-- File path yanking
map("n", "<leader>fy", "<cmd>EasyYankPath<cr>", { desc = "Yank path" })
map("n", "<leader>fa", "<cmd>EasyYankAbsPath<cr>", { desc = "Yank absolute path" })
