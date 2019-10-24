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
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-jp/vital.vim'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'Valloric/YouCompleteMe'
" Requires running install script
Plugin 'rdnetto/YCM-Generator'
" Plugin 'vim-syntastic/syntastic'
Plugin 'dense-analysis/ale'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" community/awesome-terminal-fonts
Plugin 'altercation/vim-colors-solarized'
Plugin 'joshdick/onedark.vim'
" requires copying files (see install section)
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'honza/vim-snippets'
Plugin 'SirVer/ultisnips'
Plugin 'skywind3000/asyncrun.vim'
Plugin 'majutsushi/tagbar'
" extra/ctags
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mrk21/yaml-vim'
Plugin 'vim-python/python-syntax'
Plugin 'godlygeek/tabular'
Plugin 'davidhalter/jedi-vim'
"Plugin 'vim-scripts/OmniCppComplete'
Plugin 'tell-k/vim-autopep8'
Plugin 'ajh17/vimcompletesme'
call vundle#end()

" community/bandit

filetype plugin indent on

set termguicolors
let g:airline#extensions#ycm#enabled=1
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#ycm#error_symbol = 'E:'
let g:airline#extensions#ycm#warning_symbol = 'W:'
" colorscheme koehler
let g:airline_theme='cobalt2'
set laststatus=2
set ttimeoutlen=50
set t_Co=256

syntax on
set splitbelow
set splitright
set autoread  " Auto reload file after external command
set hlsearch


let g:NERDTreeWinSize=40
let g:Tlist_WinWidth=40
"set showtabline=2
" set timeoutlen=1000 ttimeoutlen=10

set wildmenu " Visual autocomplete for command menu
set tags=tags; " Find tags recursively

" Make completion menu behave like an IDE
set completeopt=longest,menuone,preview

colorscheme onedark

set nu
set tabstop=4
set softtabstop=4
set shiftwidth=4
"let g:UltiSnipsExpandTrigger=","
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:ycm_register_as_syntastic_checker = 1
let g:syntastic_enable_highlighting = 1
let g:Show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 1 " default 0
let g:ycm_open_loclist_on_ycm_diags = 1

let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_min_num_identifier_candidate_chars = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_max_num_identifier_candidates = 0
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
"let g:ycm_key_list_select_completion = ['<tab>', '<Down>']
"let g:ycm_key_list_previous_completion = ['<s-tab>', '<Up>']
let g:ycm_global_ycm_extra_conf = "$HOME/.vim/.ycm_extra_conf.py"
let python_highlight_all=1
let g:python_highlight_builtins=1
let g:python_highlight_string_format=1
let g:python_hightlight_class_vars=1
let g:autopep8_disable_show_diff=1
"flake8's map is greedy, turn it off
let no_flake8_maps = 1


let g:ale_linters = {
	\ 'python' : ['flake8'] ,
	\ 'c' : ['gcc'] ,
	\ 'cpp' : ['g++'] ,
	\ }
let g:ale_c_gcc_executable = '/usr/bin/gcc'
let g:ale_c_gcc_options = '-Wall -std=c11'
let g:ale_cpp_gcc_executable = '/usr/bin/g++'
let g:ale_cpp_gcc_options = '-Wall -std=c11'
" Maps


let mapleader = ","

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
"ctags black magic
nnoremap <Leader>. :CtrlPTag<cr>

"spell check.
map <leader>o :setlocal spell! spelllang=en_us<CR>

map <F3> :YcmCompleter GoTo<CR>
"map <leader>g  : YcmCompleter GoToDefinitionElseDeclaration<CR>
map <leader><tab> :bnext<cr>

map <F6> :NERDTreeToggle<CR>
noremap <leader>d :bp<cr>:bd #<cr>
nmap <F7> :TagbarToggle<CR>
" Redraw the screen and remove highlighting
nnoremap <silent> <C-l> :nohl<CR><C-l>


" AutoCmds


autocmd BufWritePre * %s/\s\+$//e
autocmd FileType python map <buffer> <F8> :call flake8#Flake8()<CR>
autocmd BufNewFile,BufRead *.py
	\ set colorcolumn=80 |
	\ set expandtab |
	\ set autoindent |  " Copy indentation from previous line
	\ set fileformat=unix |
	\ let g:ycm_python_binary_path = 'python' |
	" \ let g:syntastic_python_checkers = ['flake8'] |
	\ nnoremap <leader>p :Autopep8<cr> |
	\ nnoremap <buffer> <F5> :exec '!ipython -i' shellescape(@%, 1)<cr> |
	\ nnoremap <buffer> <F4> :exec '!ipython -d' shellescape(@%, 1)<cr>

autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
 autocmd BufNewFile,BufRead *.cpp,*.cxx,*.c,*.h,*.hpp,*.hxx,*.asm
 	\ set expandtab |
 	\ set autoindent | " Copy indentation from previous line
 	\ set colorcolumn=110 |
 	\ let &path.="src/include,/usr/include/AL,/usr/include/linux" . ',/lib/modules/' . system('/usr/bin/uname -r') . '/build/include' |
 	\ nnoremap <buffer> <F5> :AsyncRun make -j8<cr> |
 	\ nnoremap <buffer> <F4> :AsyncRun make clean && make -j8<cr>

" markdown
autocmd BufNewFile,BufRead *.md
	\ map <leader>c :w! \| :AsyncRun pandoc --pdf-engine=xelatex -s -o '%:r.pdf' <c-r>%<CR> |
	\ map <leader>m :w! \| :AsyncRun mimeopen '%:r.pdf'<CR>

"YAML file config from
"https://lornajane.net/posts/2018/vim-settings-for-working-with-yaml
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab


" Functions


" Borrowing airline's example
function! AirlineThemePatch(palette)
	let a:palette.accents.running = [ '', '', '', '', '']
	let a:palette.accents.success = [ '#00ff00', '', 'green', '', '']
	let a:palette.accents.failure = [ '#ff0000', '', 'red', '', '']
endfunction
let g:airline_theme_patch_func = 'AirlineThemePatch'

let g:async_status_old = ''
function! Get_asyncrun_running()
	let async_status = g:asyncrun_status
	if async_status != g:async_status_old
		if async_status == 'running'
			call airline#parts#define_accent('asyncrun_status', 'running')
		elseif async_status == 'success'
			call airline#parts#define_accent('asyncrun_status', 'success')
		elseif async_status == 'failure'
			call airline#parts#define_accent('asyncrun_status', 'failure')
		endif

		let g:airline_section_x = airline#section#create(['asyncrun_status'])
		AirlineRefresh
		let g:async_status_old = async_status
	endif
	return async_status
endfunction

call airline#parts#define_function('asyncrun_status', 'Get_asyncrun_running')
let g:airline_section_x = airline#section#create(['asyncrun_status'])




" useful things for later
" :h w18
" :h syn
" :h mysyntaxfile-add
" hi def link
" C-[ and C-t with ctags
"
