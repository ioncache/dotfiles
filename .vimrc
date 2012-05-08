runtime bundle/vim-pathogen/autoload/pathogen.vim
" Bundle: tpope/vim-pathogen
call pathogen#infect()

" Bundle: git://github.com/altercation/vim-colors-solarized.git
" Bundle: git://github.com/bronson/vim-trailing-whitespace.git
" Bundle: git://github.com/ervandew/supertab.git
" Bundle: git://github.com/henrik/vim-indexed-search.git
" Bundle: https://github.com/Lokaltog/vim-powerline 
" Bundle: git://github.com/scrooloose/nerdcommenter.git
" Bundle: git://github.com/scrooloose/nerdtree.git
" Bundle: git://github.com/scrooloose/syntastic.git
" Bundle: git://github.com/tpope/vim-fugitive.git
" Bundle: git://github.com/tpope/vim-git.git
" Bundle: git://github.com/vim-scripts/closetag.vim.git
" Bundle: git://github.com/vim-scripts/ctrlp.vim.git
" Bundle: git://github.com/vim-scripts/perl-support.vim.git
" Bundle: git://github.com/vim-scripts/taglist.vim.git
" Bundle: git://github.com/vim-scripts/yaifa.vim.git

" Some basic VIM settings

au BufReadPost *.pl   set keywordprg=perldoc\ -f
colorscheme solarized
filetype plugin indent on
set background=dark
set bs=2
set encoding=utf-8
set fillchars+=stl:\ ,stlnc:\
set foldlevel=99
set foldmethod=indent
set hidden
set history=1000
set laststatus=2
set mouse=a
set number
set t_Co=256
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
syntax enable

" tabs
set softtabstop=4
set shiftwidth=4
set tabstop=4
set smarttab
set expandtab

" indents
set smartindent
set autoindent

" some Perl settings
autocmd FileType perl set showmatch
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

" plugin specific settings

" NERTTree config
map <leader>n :NERDTreeToggle<CR>

" syntastic config
set matchpairs=(:),{:},[:],<:>
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1
let g:syntastic_quiet_warnings=1

" Powerline config
let g:Powerline_symbols = 'fancy'