call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bronson/vim-trailing-whitespace'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'henrik/vim-indexed-search'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'rstacruz/vim-hyperstyle'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/SearchComplete'
Plug 'vim-scripts/yaifa.vim'

call plug#end()

" Some basic VIM settings

au BufReadPost *.pl   set keywordprg=perldoc\ -f
colorscheme desert
filetype plugin indent on
nnoremap j gj
nnoremap k gk
set background=dark
set bs=2
set encoding=utf-8
set fillchars+=stl:\ ,stlnc:\
set foldlevel=99
set foldmethod=indent
set hidden
set history=1000
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set number
set showmatch
set smartcase
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set t_Co=256
set undolevels=1000
syntax enable

" tabs
set softtabstop=2
set shiftwidth=2
set tabstop=2
set smarttab
set expandtab

" indents
set autoindent
set copyindent
set smartindent

" word wrap vimdiff
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

" some Perl settings
"autocmd FileType perl set showmatch
command -range=% -nargs=* Tidy <line1>,<line2>!
  \perltidy -pbp <args>

" key remaps

" Indent using tabs (while in visual mode)
vnoremap < <gv
vnoremap > >gv

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

" make tab in normal mode ident code
nmap <tab> I<tab><esc>
nmap <s-tab> ^i<bs><esc>

" remap leader key
let mapleader = ","

nmap <silent> ,/ :nohlsearch<CR>

" plugin specific settings

" NERDTTree config
map <leader>n :NERDTreeToggle<CR>

" syntastic config
set matchpairs=(:),{:},[:],<:>
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']

" Airline config
let g:airline_powerline_fonts = 1

" multi-cursor config
let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" commands
command! -bar -nargs=0 Sudow   :silent exe "write !sudo tee % >/dev/null"|silent edit!
