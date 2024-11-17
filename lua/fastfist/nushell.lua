local M = {}

local last_command_run = {
	shell = "nushell",
	cmd = "",
}

local function strip_ansi(str)
	-- More comprehensive ANSI escape sequence patterns
	local patterns = {
		"\27%[%d+[%;%d]*m", -- Color and style
		"\27%[%d+[%;%d]*[ABCD]", -- Cursor movement
		"\27%[%d+[%;%d]*[EFGH]", -- Cursor position
		"\27%[%d*[JKPS]", -- Clear screen/line and save/restore position
		"\27%[%?%d+[hl]", -- Terminal modes
		"\27%[[=>]%d*[%;%d]*%a", -- Other sequences
		"\27%([AB012]", -- Alternative patterns
		"\27%[%d+[%;%d]*[fimnsu]", -- Other SGR sequences
	}

	for _, pattern in ipairs(patterns) do
		str = str:gsub(pattern, "")
	end
	return str
end
-- Create a floating window
local function create_float()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.wo[win].wrap = false
	vim.keymap.set("n", "q", ":q<CR>", { buffer = buf, silent = true })
	vim.keymap.set("n", "<Esc>", ":q<CR>", { buffer = buf, silent = true })

	return buf, win
end

-- Execute nushell command
local function execute_nu(command)
	-- Create temp file with unique name
	local tmp_file = os.tmpname()
	local f = io.open(tmp_file, "w")
	if not f then
		return {}
	end

	-- Write command to temp file
	f:write(command)
	f:close()

	-- Execute the file with nushell
	local output = vim.fn.system("nu " .. tmp_file)

	os.remove(tmp_file)
	local lines = vim.split(output, "\n")
	local cleaned_lines = {}
	for _, line in ipairs(lines) do
		table.insert(cleaned_lines, strip_ansi(line))
	end
	return cleaned_lines

	-- -- Split and return output
	-- return vim.split(output, "\n")
end

-- Get frontmatter content
local function get_frontmatter()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local frontmatter = {}

	table.insert(
		frontmatter,
		[[
		def "from env" []: string -> record {
		lines 
    | split column '#' # remove comments
    | get column1 
    | parse "{key}={value}"
    | str trim value -c '"' # unquote values
    | transpose -r -d
		}
		]]
	)
	local cols = math.floor(vim.o.columns * 0.8)

	table.insert(frontmatter, "source $nu.config-path")
	table.insert(frontmatter, 'if ($"($env.PWD)/.env" | path exists) { open .env | load-env }')
	table.insert(frontmatter, "alias core-table = table")
	table.insert(frontmatter, "alias table = table -w " .. cols)

	for i, line in ipairs(lines) do
		if line:match("^###%s*$") then
			-- Extract all non-comment lines before the separator
			for j = 1, i - 1 do
				local fm_line = lines[j]
				if not fm_line:match("^%s*#") and not fm_line:match("^%s*$") then
					table.insert(frontmatter, fm_line)
				end
			end
			break
		end
	end

	return table.concat(frontmatter, "\n")
end

local function get_current_command()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local start_line = current_line
	local end_line = current_line

	-- Search backwards for the start of the command block
	for i = current_line - 1, 1, -1 do
		local line = lines[i]
		if line:match("^%s*$") then
			break
		end
		start_line = i
	end

	-- Search forwards for the end of the command block
	for i = current_line, #lines do
		local line = lines[i]
		if line:match("^%s*$") then
			break
		end
		end_line = i
	end

	-- Get the block of lines
	return table.concat(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")
end

-- Run command with frontmatter
function M.run_with_nu()
	local command = get_current_command()
	if command == "" then
		return
	end

	local frontmatter = get_frontmatter()
	local buf, _ = create_float()
	local output = {}

	-- Execute main command
	local fullCommand = frontmatter .. "\n\n" .. command
	local cmd_output = execute_nu(fullCommand)

	last_command_run.shell = "nushell"
	last_command_run.cmd = fullCommand

	for _, line in ipairs(cmd_output) do
		table.insert(output, line)
	end

	-- Set buffer content and options
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = "nushell"
end

function M.run_with_zsh()
	local command = get_current_command()
	if command == "" then
		return
	end
	local buf, _ = create_float()
	local output = {}

	last_command_run.shell = "zsh"
	last_command_run.cmd = command

	-- Execute command in zsh
	local cmd = io.popen('zsh -c "' .. command:gsub('"', '\\"') .. '" 2>&1')
	if cmd then
		for line in cmd:lines() do
			table.insert(output, line)
		end
		cmd:close()
	end

	-- Set buffer content and options
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = "sh"
end

function M.rerun_last_command()
	local buf, _ = create_float()
	local output = {}
	local command = last_command_run.cmd
	if last_command_run.shell == "nushell" then
		local cmd_output = execute_nu(command)

		last_command_run.shell = "nushell"
		last_command_run.cmd = command

		for _, line in ipairs(cmd_output) do
			table.insert(output, line)
		end

		-- Set buffer content and options
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
		vim.bo[buf].modifiable = false
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].filetype = "nushell"
	elseif last_command_run.shell == "zsh" then
		local cmd = io.popen('zsh -c "' .. command:gsub('"', '\\"') .. '" 2>&1')
		if cmd then
			for line in cmd:lines() do
				table.insert(output, line)
			end
			cmd:close()
		end

		-- Set buffer content and options
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
		vim.bo[buf].modifiable = false
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].filetype = "sh"
	end
end

-- Setup function
function M.setup()
	vim.api.nvim_create_user_command("NuRun", function()
		M.run_with_nu()
	end, {})

	vim.keymap.set("n", "<Leader>;r", M.run_with_nu, { silent = true, desc = "Run with nushell" })
	vim.keymap.set("n", "<Leader>;z", M.run_with_zsh, { silent = true, desc = "Run with zsh" })
	vim.keymap.set("n", "<Leader>;a", M.rerun_last_command, { silent = true, desc = "Rerun last command" })
end

return M
