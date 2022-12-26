let mapleader = " "

if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
echo "Downloading junegunn/vim-plug to manage plugins..."
silent !mkdir -p ~/.config/nvim/autoload/
silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'tomlion/vim-solidity'

" IDK just some visual stuffs
Plug 'bling/vim-airline' " TODO
Plug 'tpope/vim-commentary'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'vimwiki/vimwiki'

" Work flow stuffs
Plug 'kyazdani42/nvim-web-devicons'
Plug 'preservim/nerdtree'

Plug 'sindrets/diffview.nvim'
Plug 'TimUntersberger/neogit'
Plug 'tpope/vim-surround'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/popup.nvim' " TODO

" Harpoon
Plug 'ThePrimeagen/harpoon' " TODO
Plug 'nvim-lua/plenary.nvim' " hapoon requirement 


" NVIM-LSP
Plug 'neovim/nvim-lspconfig'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim' " TODO

"Java
Plug 'mfussenegger/nvim-jdtls'

" COMPE

" COQ 
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
" 9000+ Snippets
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
" Need to **configure separately**

Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
" - shell repl
" - nvim lua api
" - scientific calculator
" - comment banner
" - etc


" Tree sitter and color schemes
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'

" Color Schemes
Plug 'shaunsingh/nord.nvim'
Plug 'Mofiqul/dracula.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

call plug#end()

if exists("g:neovide")
    " Neovide setings
    let g:neovide_refresh_rate=120
    let g:neovide_transparency=0.8
    let g:neovide_cursor_trail_length=2.0
    let g:neovide_cursor_vfx_mode="sonicboom"
    set guifont=mono:14
endif

func! WordProcessor()
  " movement changes
  map j gj
  map k gk
  map $ g$
  map 0 g0
  " formatting text
  setlocal formatoptions=1
  setlocal noexpandtab
  setlocal wrap
  setlocal linebreak
  " spelling and thesaurus
  setlocal spell spelllang=en_us
  set thesaurus+=/home/test/.vim/thesaurus/mthesaur.txt
  " complete+=s makes autocompletion search the thesaurus
  set complete+=s
endfu

" Colorscheme stuffs
let g:tokyonight_transparent = 1
let g:tokyonight_style = "storm"
" let g:dracula_colorterm = 0

let g:nord_contrast = v:true
let g:nord_borders = v:false
let g:nord_disable_background = v:true
let g:nord_italic = v:false

" Limelight
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
let g:limelight_default_coefficient = 0.7
let g:limelight_paragraph_span = 2
let g:limelight_priority = 10

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!


lua << EOF

require'dracula'.setup({
  transparent_bg = true
})

EOF

" Lua way of colorscheme
" colorscheme dracula
colorscheme dracula
" colorscheme tokyonight

let g:gruvbox_contrast_dark = "medium"
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
set completeopt=menuone,noinsert,noselect

set bg=dark
set go=a
set mouse=a
set nohlsearch
set clipboard=unnamedplus
set hidden
set wildignore+=*.pyc,*.o,*.obj,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.*

" Tabs
set tabstop=4
set expandtab
set shiftwidth=4

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" Vim fugitive
map <leader>gs <cmd>lua require('neogit').open()<CR>

nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>

nnoremap <leader>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>gr <cmd>lua vim.lsp.buf.references()<CR>

nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
xnoremap <leader>a <cmd>lua vim.lsp.buf.range_code_action()<CR>

nnoremap<C-p> <cmd>Telescope find_files<CR>

au TextYankPost * silent! lua vim.highlight.on_yank{ on_visual=true }

lua << EOF

require('neogit').setup({
  integrations = {
    diffview = true
  },
})

vim.g.gui_font_default_size = 5

require'nvim-treesitter.configs'.setup{
    highlight = { enable = true },
    indent = { enable = true }
}

vim.g.coq_settings = { 
    auto_start = "shut-up",
    keymap = {
        jump_to_mark = "null",
        bigger_preview = "null"
    } 
}

local lsp = require'lspconfig'
local coq = require'coq'


lsp.pyright.setup{coq.lsp_ensure_capabilities()}
lsp.rust_analyzer.setup{coq.lsp_ensure_capabilities()}
lsp.tsserver.setup{coq.lsp_ensure_capabilities()}
lsp.clangd.setup{coq.lsp_ensure_capabilities()}
lsp.tailwindcss.setup{coq.lsp_ensure_capabilities()}
lsp.hls.setup{coq.lsp_ensure_capabilities()}

" lsp.solidity_ls.setup{
" coq.lsp_ensure_capabilities(),
"     capabilities = capabilities,
"     root_dir = lsp.util.root_pattern('hardhat.config.*', '.git'),
" }

" lsp.solc.setup {
"     coq.lsp_ensure_capabilities(),
"     capabilities = capabilities,
"     root_dir = lsp.util.root_pattern('hardhat.config.*', '.git'),
" }

require'harpoon'.setup({
    global_settings = {
        save_on_toggle = false;
        save_on_change = true;
    },
})


vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
        severity_sort = true,
  }
)
EOF


packadd termdebug
nmap <leader>dj :Over<CR>
nmap <leader>db :Break<CR>
nmap <leader>dl :Step<CR>
nmap <leader>dc :Continue<CR>

tnoremap <Esc> <C-\><C-n>
nmap <leader>ta :lua require("harpoon.term").gotoTerminal(0)<CR>
nmap <leader>ts :lua require("harpoon.term").gotoTerminal(1)<CR>
nmap <leader>td :lua require("harpoon.term").gotoTerminal(2)<CR>
nmap <leader>tf :lua require("harpoon.term").gotoTerminal(3)<CR>

" Some basics:
nnoremap c "_c
set nocompatible
filetype plugin on
syntax on
set encoding=utf-8
set number relativenumber

" Enable autocompletion:
set wildmode=longest,list,full

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Spell-check set to <leader>o, 'o' for 'orthography':
map <leader>o :setlocal spell! spelllang=en_us<CR>
map <leader>s :setlocal spell! spelllang=es<CR>

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright

" Nerd tree
let NERDTreeRespectWildIgnore=1
map <leader>n :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Compile document, be it groff/LaTeX/markdown/etc.
map <leader>cc :w! \| !compiler <c-r>%<CR>

" Update binds when sxhkdrc is updated.
autocmd BufWritePost *sxhkdrc !pkill -USR1 sxhkd

" Update shortcuts
autocmd BufWritePost bmfiles,bmdirs !shortcuts

" For files in ftplugin to run

" Goyo
map <leader>gg :Goyo<CR>
