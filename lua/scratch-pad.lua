-- Scratch Pad Plugin for Neovim
-- Provides an interactive scratch buffer for quick notes and commands

local M = {}

-- Default configuration
M.config = {
  width = 80,
  height = 20,
  position = "right",
  border = "rounded",
  title = " Scratch Pad ",
  filetype = "scratch",
}

-- State
local scratch_buf = nil
local scratch_win = nil

-- Create or get scratch buffer
local function get_scratch_buffer()
  if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
    return scratch_buf
  end
  
  scratch_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(scratch_buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(scratch_buf, "filetype", M.config.filetype)
  vim.api.nvim_buf_set_option(scratch_buf, "swapfile", false)
  
  return scratch_buf
end

-- Calculate window position
local function get_win_config()
  local width = M.config.width
  local height = M.config.height
  local position = M.config.position
  
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines
  
  local row, col
  
  if position == "right" then
    row = math.floor((screen_height - height) / 2)
    col = screen_width - width - 2
  elseif position == "left" then
    row = math.floor((screen_height - height) / 2)
    col = 2
  elseif position == "top" then
    row = 2
    col = math.floor((screen_width - width) / 2)
  elseif position == "bottom" then
    row = screen_height - height - 2
    col = math.floor((screen_width - width) / 2)
  else
    row = math.floor((screen_height - height) / 2)
    col = math.floor((screen_width - width) / 2)
  end
  
  return {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = M.config.border,
    title = M.config.title,
    title_pos = "center",
  }
end

-- Open scratch pad
function M.open()
  local buf = get_scratch_buffer()
  local win_config = get_win_config()
  
  scratch_win = vim.api.nvim_open_win(buf, true, win_config)
  
  vim.api.nvim_win_set_option(scratch_win, "wrap", true)
  vim.api.nvim_win_set_option(scratch_win, "linebreak", true)
  vim.api.nvim_win_set_option(scratch_win, "cursorline", true)
  
  local opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", function() M.close() end, opts)
  vim.keymap.set("n", "<Esc>", function() M.close() end, opts)
  
  if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
    local welcome = {
      "# Scratch Pad",
      "",
      "This is a temporary buffer for quick notes.",
      "",
      "- Press `q` or `<Esc>` to close",
      "- Content persists during session",
      "",
      "---",
      "",
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, welcome)
  end
  
  vim.api.nvim_win_set_cursor(scratch_win, { vim.api.nvim_buf_line_count(buf), 0 })
end

-- Close scratch pad
function M.close()
  if scratch_win and vim.api.nvim_win_is_valid(scratch_win) then
    vim.api.nvim_win_close(scratch_win, true)
    scratch_win = nil
  end
end

-- Toggle scratch pad
function M.toggle()
  if scratch_win and vim.api.nvim_win_is_valid(scratch_win) then
    M.close()
  else
    M.open()
  end
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  vim.api.nvim_create_user_command("ScratchPad", function()
    M.open()
  end, { desc = "Open scratch pad" })
  
  vim.api.nvim_create_user_command("ScratchPadToggle", function()
    M.toggle()
  end, { desc = "Toggle scratch pad" })
  
  vim.api.nvim_create_user_command("ScratchPadClose", function()
    M.close()
  end, { desc = "Close scratch pad" })
end

return M