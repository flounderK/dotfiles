scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,uft8,prc

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Bundle 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'altercation/vim-colors-solarized'
Plugin 'joshdick/onedark.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'honza/vim-snippets'
Plugin 'SirVer/ultisnips'


call vundle#end()

filetype plugin indent on

set termguicolors
let g:airline#extensions#ycm#enabled=1
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
" colorscheme koehler
let g:airline_theme='cobalt2'
set laststatus=2
set ttimeoutlen=50
set t_Co=256






syntax on
set splitbelow
set splitright
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

map <F6> :NERDTreeToggle<CR>
"set showtabline=2
" set timeoutlen=1000 ttimeoutlen=10


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

autocmd BufNewFile,BufRead *.py
	\ set textwidth=79 |
	\ set colorcolumn=80 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=unix |
	\ let g:ycm_python_binary_path = 'python' |
	\ nnoremap <buffer> <F5> :exec '!python -i' shellescape(@%, 1)<cr> |
	\ nnoremap <buffer> <F4> :exec '!python -d' shellescape(@%, 1)<cr>

"autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd BufNewFile,BufRead *.cpp
	\ set expandtab |
	\ set autoindent |
	\ set colorcolumn=110 |
	\ let &path.="src/include,/usr/include/AL," |
	\ set makeprg=make\ -C\ ../build\ -j9 |
	\ nnoremap <F4> :make!<cr> |
	\ nnoremap <F5> :exec '!' shellescape(@%,1)<CR>

autocmd BufNewFile,BufRead *.c
	\ set expandtab |
	\ set autoindent |
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

