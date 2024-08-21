" Very basic vim config
scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,uft8,prc
set ttyfast
" Disable bell
set visualbell                  " Disable visual bell
set noerrorbells                " Disable error bell
set showcmd
set nocompatible
filetype off


let mapleader = ","

set nu
set ruler
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace guibg=red
autocmd BufEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhiteSpace /\s\+$/

""" Window/Buffer movement
" Buffers
nmap <Leader>J :bnext<CR>
nmap <Leader>K :bprev<CR>
" Windows
nmap <Leader>k :wincmd k<CR>
nmap <Leader>j :wincmd j<CR>
nmap <Leader>h :wincmd h<CR>
nmap <Leader>l :wincmd l<CR>

" Delete extra whitespace
nnoremap <Leader>d :%s/\s\+$//<CR>
