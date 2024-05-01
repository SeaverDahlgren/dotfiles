set nocompatible
set encoding=utf-8
set backspace=eol,start,indent

set hidden
set history=500
set ttimeoutlen=10
set lazyredraw
set noswapfile
set nobackup

" Styling
syntax on
filetype plugin indent on
let g:netrw_banner=0
let g:netrw_liststyle=3

nnoremap <Space> <Nop>
let mapleader = " "

set mouse=a
set number
set splitbelow splitright
set wrap

set laststatus=0
set ruler
set showcmd
set showmode

set wildmenu
set wildignore=*.o,*.so,.pyc,.git,.DS_Store
set ignorecase
set smartcase
set hlsearch
set incsearch
set showmatch
set autoindent
set expandtab
set smarttab
set tabstop=4
set shiftwidth=4

" Provide Relative numer
set relativenumber number

augroup autogroup
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
    autocmd FileType text,markdown,tex setlocal spell
augroup END

nnoremap Y y$

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>x :sp<CR>
nnoremap <leader>v :vs<CR>

" nnoremap <leader>l :b#<CR>
nnoremap <leader><leader> :b#<CR>

nnoremap <leader>f :find<Space>
nnoremap <leader>b :ls<CR>:b<Space>
nnoremap <C-f> :Explore<CR>
inoremap <C-l> <C-g>u<Esc>[s1z=`]a<C-g>u

" Stop Highlighting on Query
nnoremap <esc><esc> :noh<return><esc>

" map j to escape key
inoremap jj <Esc>

" Set clipboard to copy-paste register
set clipboard=unnamed
