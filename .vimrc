scriptencoding utf-8
set encoding=utf-8
set enc=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,uft8,prc

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Plugin 'gmarik/vundle'
Plugin 'vim-scripts/indentpython.vim'
Bundle 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'altercation/vim-colors-solarized'
Plugin 'joshdick/onedark.vim'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'majutsushi/tagbar'
Plugin 'honza/vim-snippets'
Plugin 'SirVer/ultisnips'

filetype plugin indent on

syntax on
set splitbelow
set splitright
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

map <F6> :NERDTreeToggle<CR>
set laststatus=2
"set showtabline=2
set timeoutlen=1000 ttimeoutlen=10

set background=light
colorscheme onedark

set nu
set tabstop=4 
set softtabstop=4 
set shiftwidth=4 
"let g:UltiSnipsExpandTrigger=","
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_min_num_identifier_candidate_chars = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_max_num_identifier_candidates = 0

"let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
"let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
let g:ycm_key_list_select_completion = ['<tab>', '<Down>']
let g:ycm_key_list_previous_completion = ['<s-tab>', '<Up>']
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
map <F3> :YcmCompleter GoTo<CR>
"map <leader>g  : YcmCompleter GoToDefinitionElseDeclaration<CR>
let mapleader = ","
let python_highlight_all=1

au BufNewFile,BufRead *.py
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=79 |
	\ set colorcolumn=80 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=unix |
	\ set nu |
	\ set encoding=utf-8 |
	\ let g:ycm_python_binary_path = 'python' |
	\ nnoremap <buffer> <F5> :exec '!python -i' shellescape(@%, 1)<cr> |
	\ nnoremap <buffer> <F4> :exec '!python -d' shellescape(@%, 1)<cr>

au Filetype html
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set nu |
	\ set autoindent |
	\ set expandtab |
	\ set encoding=utf-8 |
	\ nnoremap <buffer> <F5> :exec '!xdg-open' shellescape(@%, 1)<CR>

au Filetype css
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set nu |
	\ set autoindent |
	\ set expandtab |
	\ set encoding=utf-8 

au Filetype js
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set nu |
	\ set expandtab |
	\ set autoindent |
	\ nnoremap <buffer> <F5> :exec '!node' shellescape(@%, 1)<CR>

"autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
au Filetype cpp
	\ set tabstop=4 |
	\ set softtabstop=4 | 
	\ set shiftwidth=4 |
	\ set expandtab |
	\ set autoindent |
	\ set nu |
	\ set encoding=utf-8 |
	\ set colorcolumn=110 |
	\ let &path.="src/include,/usr/include/AL," |
	\ set makeprg=make\ -C\ ../build\ -j9 |
	\ nnoremap <F4> :make!<cr> |
	\ nnoremap <F5> :exec '!' shellescape(@%,1)<CR>
au Filetype c
	\ set tabstop=4 |
	\ set softtabstop=4 | 
	\ set shiftwidth=4 |
	\ set expandtab |
	\ set autoindent |
	\ set nu |
	\ set encoding=utf-8 |
	\ set colorcolumn=110 |
	\ let &path.="src/include,/usr/include/AL,/lib/modules/5.1.5-arch1-2-ARCH/build/include" |
	\ set makeprg=make\ -C\ ../build\ -j9 |
	\ let g:ycm_python_binary_path = 'python' |
	\ nnoremap <F4> :make!<cr> |
	\ nnoremap <F5> :exec '!' shellescape(@%,1)<CR>

"augroup project
"	autocmd!
"	autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
"augroup END

