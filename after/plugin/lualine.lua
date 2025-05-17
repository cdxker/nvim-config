local function attached_clients()
  local clients = vim.lsp.get_clients()
  if next(clients) == nil then
    return ''
  end

  local client_names = ""
  for i, client in pairs(clients) do
    if i == 1 then
      client_names = client_names .. client.name
    else
      client_names = client_names .. ' | ' .. client.name
    end
  end
  return client_names
end

local colors = {
  text = '#ebdbb2',
  bg = '#282828',
  altbg = '#689d6a',
  gray = '#928374',
  purple = '#b16286',
  red = '#cc241d',
  blue = '#458588',
  bg0 = '#504945',
  yellow = '#d79921',
}

local bubbles_theme = {
  normal = {
    a = { bg = colors.blue },
    b = { bg = colors.gray },
    c = { bg = colors.bg },

    x = { bg = colors.bg },
    y = { bg = colors.bg0 },
    z = { bg = colors.blue },
  },

  insert = { a = { bg = colors.altbg }, y = { bg = colors.bg0 } },
  visual = { a = { bg = colors.purple }, y = { bg = colors.bg0 } },
  replace = { a = { bg = colors.red }, y = { bg = colors.bg0 } },
  command = { a = { bg = colors.yellow }, y = { bg = colors.bg0 } },
}

local theme = "gruvbox"


require('lualine').setup {
  options = {
    theme = theme,
    icons_enabled = true,
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      'mode'
    },
    lualine_b = { 'branch', 'diagnostics' },
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    },
    lualine_x = { attached_clients, 'filetype' },
    lualine_y = { 'diff' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
  },
  winbar = {
  },
  inactive_winbar = {
  },
  extensions = {}
}

vim.opt.winbar = "%f %m"


vim.opt.laststatus = 3
