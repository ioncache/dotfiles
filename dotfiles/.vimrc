if has('nvim')
    call plug#begin(stdpath('data') . '/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bronson/vim-trailing-whitespace'
Plug 'editorconfig/editorconfig-vim'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mg979/vim-visual-multi'
Plug 'preservim/tagbar'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'

call plug#end()

" Some basic VIM settings

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
if has('termguicolors')
    set termguicolors
endif
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
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

nnoremap <silent> <Leader>b :call ToggleBackground()<CR>
function! ToggleBackground()
    if &background == "light"
        set background=dark
    else
        set background=light
    endif
endfunction

" plugin specific settings

" NERDTTree config
map <leader>n :NERDTreeToggle<CR>

" ale config
set matchpairs=(:),{:},[:],<:>
let g:ale_linters = {'javascript': ['eslint']}
let g:ale_fix_on_save = 0
let g:ale_open_list = 1
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0

" Airline config
let g:airline_powerline_fonts = 1

" vim-visual-multi config
let g:VM_default_mappings = 1

" commands
command! -bar -nargs=0 Sudow :silent exe "write !sudo tee % >/dev/null"|silent edit!
