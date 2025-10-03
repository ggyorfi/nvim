local M = {}

local buf = nil
local win = nil

local cheatsheet_content = [[
  MOTIONS
    h, j, k, l         ← ↓ ↑ →                    w, b, e             Next/Prev/End word             gg, G             Start/End of file
    0, ^, $            Start/First/End line       {, }                Prev/Next paragraph            %                 Matching bracket
    f{c}, F{c}         Find char fwd/back         t{c}, T{c}          Till char fwd/back             ;, ,              Repeat f/F/t/T
    H, M, L            Top/Mid/Bottom screen      Ctrl-u, Ctrl-d      Scroll half page up/down       Ctrl-b, Ctrl-f    Page up/down
    *, #               Search word fwd/back

  EDITING
    i, a               Insert before/after        I, A                Insert start/end line          o, O              Open line below/above
    s, S               Substitute char/line       r{c}                Replace char                   R                 Replace mode
    u, Ctrl-r          Undo/Redo                  .                   Repeat last change             J                 Join lines
    >>, <<             Indent/Unindent            ==                  Auto-indent line               =G, =gg           Indent to end/start

  OPERATORS (combine with motions)
    d{motion}          Delete                     dd, D               Delete line/to end             c{motion}         Change
    cc, C              Change line/to end         y{motion}           Yank (copy)                    yy, Y             Yank line/to end
    p, P               Paste after/before         gU, gu, g~          Upper/Lower/Toggle case        >, <              Indent/Unindent

  TEXT OBJECTS (use with operators: d, c, y, etc.)
    iw, aw             Inner/Around word          iW, aW              Inner/Around WORD              is, as            Inner/Around sentence
    ip, ap             Inner/Around paragraph     i(, a(, i), a)      Inner/Around ()                i{, a{, i}, a}    Inner/Around {}
    i[, a[, i], a]     Inner/Around []            i<, a<, i>, a>      Inner/Around <>                i", a", i', a'    Inner/Around quotes
    i`, a`             Inner/Around backticks     it, at              Inner/Around tag

  VISUAL MODE
    v                  Visual mode                V                   Visual line mode               Ctrl-v            Visual block mode
    gv                 Reselect last selection    o                   Toggle cursor to other end     U, u              Upper/Lowercase

  SEARCH & REPLACE
    /pattern           Search forward             ?pattern            Search backward                n, N              Next/Prev match
    :s/old/new/        Replace in line            :s/old/new/g        Replace all in line            :%s/old/new/g     Replace all in file
    :%s/old/new/gc     Replace all (confirm)

  MARKS & JUMPS
    m{a-z}             Set mark                   '{a-z}              Jump to mark (line)            `{a-z}            Jump to mark (exact)
    ''                 Jump to prev position      Ctrl-o, Ctrl-i      Jump older/newer               g;, g,            Go to older/newer change

  REGISTERS
    "{a-z}             Use register a-z           "0                  Last yank                      "+, "*            System clipboard
    :reg               Show all registers

  WINDOWS
    Ctrl-w s           Split horizontal           Ctrl-w v            Split vertical                 Ctrl-w h,j,k,l    Move to window
    Ctrl-w w           Next window                Ctrl-w c            Close window                   Ctrl-w o          Close other windows
    Ctrl-w =           Balance windows            Ctrl-w _            Maximize height                Ctrl-w |          Maximize width

  FOLDING
    za                 Toggle fold                zA                  Toggle recursively             zo, zc            Open/Close fold
    zO, zC             Open/Close recursively     zR, zM              Open/Close all folds           zz, zt, zb        Center/Top/Bottom

  G-MOTIONS
    gd, gD             Go to def local/global     gf                  Go to file under cursor        gi                Insert at last pos
    gv                 Reselect last visual       gj, gk              Move by display line           gq{motion}        Format text

  MACROS
    q{a-z}             Record macro               @{a-z}              Play macro                     @@                Repeat last macro

  MISC
    :w                 Save                       :q, :q!             Quit/Force quit                :wq, ZZ           Save & quit
    :x                 Save & quit (if modified)  Ctrl-g              Show file info                 :help {topic}     Get help

  Press 'q' or <Esc> to close
]]

function M.toggle()
	-- If window is open, close it
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
		win = nil
		buf = nil
		return
	end

	-- Create buffer if it doesn't exist
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch buffer

		-- Set buffer options
		vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
		vim.api.nvim_set_option_value("filetype", "cheatsheet", { buf = buf })

		-- Set content
		local lines = vim.split(cheatsheet_content, "\n")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		-- Create namespace and define highlight
		local ns = vim.api.nvim_create_namespace("cheatsheet")
		vim.cmd([[highlight CheatsheetCommand guifg=#ffffff gui=bold]])

		-- Column positions (where commands start) - 1-indexed for string operations
		local column_starts = { 5, 24, 51, 71, 102, 120 }

		-- Add highlights
		for i, line in ipairs(lines) do
			-- Skip header lines
			if not line:match("^  [A-Z]") and line:match("^    ") then
				-- Process odd columns (1st, 3rd, 5th = indices 1, 3, 5)
				for col_idx, col_start in ipairs(column_starts) do
					if col_idx % 2 == 1 then -- Odd columns
						-- Find the end of this column (start of next column or end of line)
						local col_end = column_starts[col_idx + 1] or (#line + 1)

						-- Highlight everything in this column except commas
						local j = col_start
						while j < col_end and j <= #line do
							-- Skip spaces and commas
							while j < col_end and j <= #line and (line:sub(j, j) == " " or line:sub(j, j) == ",") do
								j = j + 1
							end

							-- Find end of command
							local cmd_start = j
							while j < col_end and j <= #line and line:sub(j, j) ~= " " and line:sub(j, j) ~= "," do
								j = j + 1
							end

							-- Highlight if we found a command (convert to 0-indexed for API)
							if j > cmd_start and cmd_start <= #line then
								vim.api.nvim_buf_set_extmark(buf, ns, i - 1, cmd_start - 1, {
									end_col = math.min(j - 1, #line),
									hl_group = "CheatsheetCommand",
								})
							end
						end
					end
				end
			end
		end

		-- Make buffer read-only
		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
		vim.api.nvim_set_option_value("readonly", true, { buf = buf })
	end

	-- Get editor dimensions
	local width = vim.o.columns
	local height = vim.o.lines

	-- Calculate max text width
	local max_text_width = 0
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		max_text_width = math.max(max_text_width, vim.fn.strdisplaywidth(line))
	end

	-- Calculate window size
	local win_width = math.min(max_text_width + 4, math.floor(width * 0.95)) -- +4 for padding, max 95% of screen
	local win_height = math.floor(height * 0.85)

	-- Calculate starting position (center)
	local row = math.floor((height - win_height) / 2 - 1)
	local col = math.floor((width - win_width) / 2)

	-- Create floating window
	win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Set window options
	vim.api.nvim_set_option_value("cursorline", false, { win = win })
	vim.api.nvim_set_option_value("number", false, { win = win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = win })

	-- Add syntax highlighting for headers
	vim.api.nvim_buf_call(buf, function()
		vim.cmd([[syntax match CheatsheetHeader "^  [A-Z].*$"]])
		vim.cmd([[highlight CheatsheetHeader guifg=#89b4fa gui=bold]])
	end)

	-- Keymaps to close the window
	local opts = { buffer = buf, silent = true, nowait = true }
	vim.keymap.set("n", "q", function()
		M.toggle()
	end, opts)
	vim.keymap.set("n", "<Esc>", function()
		M.toggle()
	end, opts)

	-- Auto-close when leaving the window
	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		buffer = buf,
		callback = function()
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
				win = nil
			end
		end,
		once = true,
	})
end

return M
