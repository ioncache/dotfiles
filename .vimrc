call plug#begin('~/.vim/plugged')

Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bronson/vim-trailing-whitespace'
Plug 'ervandew/supertab'
Plug 'henrik/vim-indexed-search'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'kchmck/vim-coffee-script'
Plug 'nono/vim-handlebars'
Plug 'petdance/vim-perl'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'rstacruz/vim-hyperstyle'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/closetag.vim'
Plug 'vim-scripts/ctrlp.vim'
Plug 'vim-scripts/SearchComplete'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/yaifa.vim'

call plug#end()

" Some basic VIM settings

au BufReadPost *.pl   set keywordprg=perldoc\ -f
colorscheme solarized
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
set softtabstop=4
set shiftwidth=4
set tabstop=4
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

" NERTTree config
map <leader>n :NERDTreeToggle<CR>

" syntastic config
set matchpairs=(:),{:},[:],<:>
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Airline config
let g:airline_powerline_fonts = 1
