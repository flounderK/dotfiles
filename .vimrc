

function! Vundleinstall()
	" Based off of vim-bootstrap's autoinstall
	let vundle_exists=expand('~/.vim/bundle/Vundle.vim')
	if !isdirectory(vundle_exists)
		if !executable("git")
			echoerr "please install git so that plugins can be installed"
			execute "q!"
		endif
		echo "installing Vundle.vim"
		echo ""
		silent exec "!\git clone https://github.com/VundleVim/Vundle.vim.git " . vundle_exists
		autocmd VimEnter * PluginInstall
	endif
endfunction
call Vundleinstall()


scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,uft8,prc
set ttyfast
" Disable bell
set visualbell                  " Disable visual bell
set noerrorbells                " Disable error bell
set belloff=all
set showcmd
set nocompatible
filetype off
if (exists(':Plugin') > -1)
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()

	Plugin 'VundleVim/Vundle.vim'
	Plugin 'vim-jp/vital.vim'
	Plugin 'vim-scripts/indentpython.vim'
	Plugin 'tpope/vim-fugitive'
	Plugin 'airblade/vim-gitgutter'
	" Plugin 'vim-scripts/cscope.vim'
	Plugin 'vim-scripts/a.vim'
	" Plugin 'Valloric/YouCompleteMe'
	" Requires running install script
	" Plugin 'rdnetto/YCM-Generator'
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
	Plugin 'PProvost/vim-ps1'
	Plugin 'rust-lang/rust.vim'
	call vundle#end()
endif

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
" set ignorecase	   " Ignore case when pattern matching
" set smartcase      " Ignores ignorecase if pattern contains uppercase
set showmatch      " flashes matching brackets


let g:NERDTreeWinSize=40
let g:Tlist_WinWidth=40
"set showtabline=2
" set timeoutlen=1000 ttimeoutlen=10

set wildmenu " Visual autocomplete for command menu
set tags=tags; " Find tags recursively

" Make completion menu behave like an IDE
set completeopt=longest,menuone,preview

if (match(join(getcompletion('', 'color'), '\|'), 'onedark') > -1)
	colorscheme onedark
else
	colorscheme elflord
endif

set nu
set ruler
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
" let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
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

" Removes lag caused by listing argument signatures, but also makes life less
" exciting
let g:jedi#show_call_signatures = "0"

let g:ale_linters = {
	\ 'python' : ['flake8'] ,
	\ 'c' : ['gcc'] ,
	\ 'cpp' : ['g++'] ,
	\ }
let g:ale_c_gcc_executable = '/usr/bin/gcc'
let g:ale_c_gcc_options = '-Wall -std=c11'
let g:ale_cpp_gcc_executable = '/usr/bin/g++'
let g:ale_cpp_gcc_options = '-Wall -std=c11'

if executable("ctags-universal")
	let g:tagbar_ctags_bin = 'ctags-universal'
endif
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
" https://vi.stackexchange.com/questions/68/autocorrect-spelling-mistakes
nnoremap <leader>fs <C-G>u<Esc>[s1z=`]a<C-G>u
" nnoremap <C-K> <Esc>[sve<C-G>
" inoremap <C-K> <Esc>[sve<C-G>
" snoremap <C-K> <Esc>b[sviw<C-G>

map <F3> :YcmCompleter GoTo<CR>
"map <leader>g  : YcmCompleter GoToDefinitionElseDeclaration<CR>
map <leader><tab> :bnext<cr>

map <F6> :NERDTreeToggle<CR>
noremap <leader>d :bp<cr>:bd #<cr>
nmap <F7> :TagbarToggle<CR>
" Redraw the screen and remove highlighting
nnoremap <silent> <leader><C-l> :nohl<CR><C-l>


" Fix accidental uppercaseing
" again, from vim-boostrap
cnoreabbrev Q! q!


" :let @a = ''
" :bufdo CopyMatches A
"
function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)

function! CopyAndSetCIndentStyle()
	let g:starting_cursor_pos = getpos(".")
	" echom "starting cursor pos " . g:starting_cursor_pos[1]
	" :/^\%(\%([a-zA-Z0-9_i\*]\%([a-zA-Z0-9_i\*]\|\r\|\s\|\n\)*\)*\)\zs(\ze
	try
		:/^\%(\%([a-zA-Z0-9_i\*]\%([a-zA-Z0-9_i\*]\|\r\|\s\|\n\)*\)*\)\zs(\ze
	catch /E486/  " not found
		" echom "returning " . getpos(".")[1]
		" force the error through for now
		silent! redraw
		return
	endtry
	" echom "starting parenthesis pos " . getpos(".")[1]
	normal "n%"
	" echom "ending parenthesis pos " . getpos(".")[1]
	try
		:/{
	catch /E486/  " not found
		silent! redraw
		return
	endtry

	let l:bracket_start = getpos(".")[1]
	" echom "bracket start line " . l:bracket_start
	" get ending bracket in visual block
	normal "v%"

	let l:bracket_end = getpos(".")[1]
	" echom "bracket end line " . l:bracket_end
	" get tab indentation out of last selected block
	" :/\%V\_^\(\s\+\)\(\W\)\@=
	let l:cmd = l:bracket_start . "," . l:bracket_end . "/\\_^\\(\\s\\+\\)\\(\\W\\)\\@="
	execute l:cmd
	" let @a = ''
	" :silent bufdo CopyMatches A
	let l:hits = []
	" not entirely certain how this part works
	silent! %s//\=len(add(l:hits, submatch(0))) ? submatch(0) : ''/gne
	" let g:indent_matches = split(@a, "\n")
	let g:indent_matches = l:hits
	let g:tab_template = g:indent_matches[0]
	let g:template_len = len(g:tab_template)
	if match(g:tab_template, " ") > -1
		" echom "using spaces"
		let &tabstop = g:template_len
		let &softtabstop = g:template_len
		let &shiftwidth = g:template_len
	elseif match(g:tab_template, "\t") > -1
		" echom "using tabs"
		let &softtabstop = -1
		let &tabstop = g:template_len
		let &shiftwidth = g:template_len
	endif
endfunction

" AutoCmds


autocmd BufRead *.inc set filetype=c

autocmd BufWritePre * %s/\s\+$//e
autocmd FileType python map <buffer> <F8> :call flake8#Flake8()<CR>
" autocmd BufNewFile,BufRead *.py
	autocmd FileType python set colorcolumn=80
	autocmd FileType python set shiftwidth=4
	" autocmd FileType python set textwidth=120
	autocmd FileType python set softtabstop=4
	autocmd FileType python set expandtab
	autocmd FileType python set autoindent   " Copy indentation from previous line
	autocmd FileType python set fileformat=unix
	autocmd FileType python let g:ycm_python_binary_path = 'python'
	" autocmd FileType python \ let g:syntastic_python_checkers = ['flake8'] |
	autocmd FileType python nnoremap <leader>p :Autopep8<cr>
	autocmd FileType python nnoremap <buffer> <F5> :exec '!ipython -i' shellescape(@%, 1)<cr>
	autocmd FileType python nnoremap <buffer> <F4> :exec '!ipython -d' shellescape(@%, 1)<cr>

autocmd filetype haskell
	\ set shiftwidth=4 |
	\ set softtabstop=4 |
	\ set expandtab |
	\ set autoindent


"autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
"BufNewFile,BufRead *.cpp,*.cxx,*.c,*.h,*.hpp,*.hxx

augroup vimrc-make
	autocmd!
	autocmd filetype make setlocal noexpandtab
augroup END

augroup vimrc-cmake
	autocmd!
	autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
	autocmd filetype cmake set autoindent
	autocmd filetype cmake set shiftwidth=4
	autocmd filetype cmake set softtabstop=4
	autocmd filetype cmake set expandtab
augroup END

augroup vimrc-javascript
	autocmd!
	autocmd BufNewFile,BufRead javascriptLists.txt setlocal filetype=javascript
	autocmd filetype javascript set autoindent
	autocmd filetype javascript set shiftwidth=4
	autocmd filetype javascript set softtabstop=4
	autocmd filetype javascript set expandtab
augroup END

augroup CBuild
	"autocmd filetype c,cpp call CopyAndSetCIndentStyle()
	autocmd filetype c,cpp set expandtab
	autocmd filetype c,cpp set autoindent " Copy indentation from previous line
	autocmd filetype c,cpp set colorcolumn=110
	autocmd filetype c,cpp nnoremap <buffer> <F5> :AsyncRun make -j8<cr>
	autocmd filetype c,cpp nnoremap <buffer> <F4> :AsyncRun make clean && make -j8<cr>
	autocmd filetype c,cpp let &path.="src/include,/usr/include/AL,/usr/include/linux" . ',/lib/modules/' . system('/usr/bin/uname -r') . '/build/include'
augroup END


" modified from https://github.com/ravishi/vim-gnu-c
function! TrySetGnuCOptions()
    if searchpos('\n  {\n    ') != [0, 0]
		" START GNU C options
		" Set various width parameters
		setlocal sw=2 ts=8 tw=78

		setlocal cinoptions=>2s,e-s,n-s,f0,{s,^-s,:s,=s,g0,+.5s,p2s,t0,(0 cindent

		" Set 'formatoptions' to break comment lines but not other lines,
		" and insert the comment leader when hitting <CR> or using "o".
		setlocal fo-=t fo+=croql

		" Set 'comments' to format dashed lists in comments.
		setlocal comments=sO:*\ -,mO:\ \ \ ,exO:*/,s1:/*,mb:\ ,ex:*/

		set cpo-=C
		" END GNU C options
		" set filetype=gnuc
    endif
endfunction

au FileType *   if &ft == 'c' | call TrySetGnuCOptions() | endif


" markdown
autocmd BufNewFile,BufRead *.md
	\ set fileencoding=utf-8 |
	\ map <leader>c :w! \| :AsyncRun pandoc --pdf-engine=xelatex -s -o '%:r.pdf' <c-r>%<CR> |
	\ map <leader>m :w! \| :AsyncRun mimeopen '%:r.pdf'<CR> |
	\ set autoindent |
	\ set expandtab

"YAML file config from
"https://lornajane.net/posts/2018/vim-settings-for-working-with-yaml
au BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab


" Functions
" vim-airline
" again, taken from boostrap-vim
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
endif


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


" if has('cscope')
" 	if filereadable("cscope.out")
" 		let $CSCOPE_DB = "cscope.out"
" 	endif
" 	if !empty($CSCOPE_DB)
" 		cscope add $CSCOPE_DB
" 		set cscopetag
" 		nnoremap <leader>fa :call cscope#findInteractive(expand('<cword>'))<CR>
" 	endif
" endif


" Shamelessly stolen from https://vim.fandom.com/wiki/Display_output_of_shell_commands_in_new_window
function! s:ExecuteInShell(command)
  let command = join(map(split(a:command), 'expand(v:val)'))
  let winnr = bufwinnr('^' . command . '$')
  silent! execute  winnr < 0 ? 'botright new ' . fnameescape(command) : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
  echo 'Execute ' . command . '...'
  silent! execute 'silent %!'. command
  silent! execute 'resize ' . line('$')
  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
  silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
  echo 'Shell command ' . command . ' executed.'
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)


function! RecursiveGrep(searchterm, ...)
	let l:flags = a:0 > 0 ? a:1 : ''
	let l:cmd = "grep . -rni " . l:flags . " '" . a:searchterm . "'"
	call s:ExecuteInShell(l:cmd)
endfunction
command! -complete=shellcmd -nargs=* GrepProj call RecursiveGrep(<f-args>)


" Reload .vimrc without having to close and re open
command! -nargs=0 ReloadVimrc :source $MYVIMRC



" Return list of matches for given pattern in given range.
" This only works for matches within a single line.
" Empty hits are skipped so search for '\d*\ze,' is not stuck in '123,456'.
" If omit match() 'count' argument, pattern '^.' matches every character.
" Using count=1 causes text before the 'start' argument to be considered.
function! GetMatches(line1, line2, pattern)
  let hits = []
  for line in range(a:line1, a:line2)
    let text = getline(line)
    let from = 0
    while 1
      let next = match(text, a:pattern, from, 1)
      if next < 0
        break
      endif
      let from = matchend(text, a:pattern, from, 1)
      if from > next
        call add(hits, strpart(text, next, from - next))
      else
        let char = matchstr(text, '.', next)
        if empty(char)
          break
        endif
        let from = next + strlen(char)
      endif
    endwhile
  endfor
  return hits
endfunction

" This creates two visual maps, / and ?, the same command you would use in normal mode.
" Visually select a range and press /, enter your usual regex and hit enter.
"function! RangeSearch(direction)
"  call inputsave()
"  let g:srchstr = input(a:direction)
"  call inputrestore()
"  if strlen(g:srchstr) > 0
"    let g:srchstr = g:srchstr.
"          \ '\%>'.(line("'<")-1).'l'.
"          \ '\%<'.(line("'>")+1).'l'
"  else
"    let g:srchstr = ''
"  endif
"endfunction
"vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
"vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>

" useful things for later
" :h w18
" :h syn
" :h mysyntaxfile-add
" hi def link
" ma " set mark a
" # " search what is under the cursor
" C-[ and C-t with ctags
"
"
"
"
"
"
