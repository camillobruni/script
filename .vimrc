set nocompatible " be iMproved
set encoding=utf-8
" force 256 colors (for instance for powerline)
"set term=xterm-256color

" buffer redraws for big files
set lazyredraw

" Set the limit of large files to 5MB
let g:LargeFile = 5

" secure non-default vimrc files
set exrc
set secure

" Prefix/namespace for user commands, set <leader> to ;
let mapleader=";"

" Configure & load bundles
runtime bundles.vim

" jslint: force node instead of javascriptcore: https://github.com/hallettj/jslint.vim/issues/31
let $JS_CMD = 'nodejs'

let g:ycm_auto_trigger = 0
" Make sure ultiSnip and YCM Completion get along by using supertab
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'
let g:SuperTabDefaultCompletionType = 'context'

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" ctrlp settings
" use lazy updating after 150ms of inactivity
let g:ctrlp_lazy_update = 150
" Always reopen files in new buffers, only reuse when <c-v> is pressed
let g:ctrlp_switch_buffer = "V"


" Use vims omni completion for eclim
" let g:EclimCompletionMethod = 'omnifunc'

" NERDCommenter settings
let g:NERDSpaceDelims = 1

" Setup bundles
let g:acp_behaviorKeywordLength = 3
let g:cssColorVimDoNotMessMyUpdatetime = 'kthxbye'
" indent guides
let g:indent_guides_indent_levels = 12
let g:indent_guides_start_level = 3
" let g:indent_guides_guide_size = 0
let g:indent_guides_auto_colors = 0

" <leader> commands
nnoremap <leader>nt :NERDTreeToggle<cr>
nnoremap <leader>tb :TagbarToggle<cr>

let g:miniBufExplForceSyntaxEnable = 1

syntax on
" Syntax coloring lines that are too long just slows down the world
set synmaxcol=2048

filetype plugin indent on
set omnifunc=syntaxcomplete#Complete

let NERDTreeIgnore=['\.pyc$', '\~$', '^\.svn', '\.o$', '\.aux$', '\.out$', '\..*\.orig$', '\.synctex.gz$', '\.toc$', '\.blg$', '\.bbl', '\.lof', '\.lot']

" enable status line always
set laststatus=2

" Session Handling https://github.com/xolox/vim-session
let g:session_autosave = 'yes'
let g:session_autoload = 'yes'

" autoread files that changed outside vim
set autoread

" make sure vim finds the tags file (not sure why and how...)
set tags=./tags;
"
" FileTypes ==================================================================
" autowrap for .txt, .tex  and .md files
" autocmd FileType tex setlocal wrap spell
" autocmd BufRead,BufNewFile *.txt setlocal wrap spell
" autocmd BufRead,BufNewFile *.md setlocal wrap spell
" do not auto-hardwrap text
set formatoptions-=t

set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch
set wildmenu wildmode=list:longest,full wildignore+=*.swp,*.bak,*.pyc,*.elc,*.zwc,*.class,*.git,*.o,*.obj
set ruler
set showcmd
set showmode
set number
set hidden
set wrap
set scrolloff=2
set visualbell
set fillchars=""
set cursorline
set nofoldenable
set history=1000

" more convenient splitting behavior for me
set splitbelow
set splitright

" Sane indentation defaults
set expandtab
set smartindent
set autoindent

" enable global undoing even after closing the file
set undofile
set undodir=~/.vim-undo
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

" mark character exceeding the 80 limit as errors
match Error /\%>80v/

function! SetIndent(...)
    let size = (a:0 == 0) ? 4 : a:1
    execute 'set tabstop=' . size
    execute 'set shiftwidth=' . size
    execute 'set softtabstop=' . size
endfunction
command! -nargs=? SetIndent call SetIndent(<f-args>)
cnoremap seti SetIndent
" call once to set the default
SetIndent

" Which EOL conventions to detect
set fileformats=unix,dos,mac

set backspace=indent,eol,start
"set cpoptions+=$ " mark changed area
set whichwrap=b,s,h,l,<,>,[,]

nmap <leader>qf :botright copen<cr>
nmap <leader>spell :setlocal spell!<cr>
nmap <leader>w :set wrap!<cr>

" Sudo write that file!
command! SudoWrite write !sudo tee % > /dev/null
cmap w!! :SudoWrite

" Invisible characters: shortcut to rapidly toggle
nmap <leader>i :set list!<cr>
set listchars=tab:▸\ ,eol:\ ,trail:·,nbsp:_,extends:→,precedes:→

" Unhighlight search results in normal mode (and still redraw screen)
nnoremap <silent> <C-l> :silent nohlsearch<cr><C-l>

" Opening files relative to current one, e.g. :e %/bar.txt
cnoremap %% <C-r>=expand('%:p:.:h') . '/' <Enter>

" search for the currently selected text
vnoremap * y/<C-R>"<CR>

" Use Ctrl-[ and Ctrl-] to navigate tags
"inoremap <C-]> <ESC><C-]>i
"inoremap <C-[> <ESC><C-t>i
"noremap  <M-[> <ESC><C-t>
"inoremap <D-.> <ESC>:

" arrow mapping ===============================================================
" arrows shouldn't jump over wrapped lines
nnoremap <Down> gj
nnoremap <Up> gk
nnoremap <buffer> <silent> <Home> g<Home>
nnoremap <buffer> <silent> <End>  g<End>

vnoremap <Down> gj
vnoremap <Up> gk
vnoremap <buffer> <silent> <Home> g<Home>
vnoremap <buffer> <silent> <End>  g<End>

inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
inoremap <buffer> <silent> <Home> <C-o>g<Home>
inoremap <buffer> <silent> <End> <C-o>g<End>

" Shift+Arrow srcoll and center
inoremap <S-Down> <ESC>gjzzi
inoremap <S-Up> <ESC>gkzzi
nnoremap <S-Down> gjzz
nnoremap <S-Up> gkzz

"" key mappings ===============================================================
"command Q q " Bind :Q to :qt
" stamp over yanked text over current word
nnoremap S diw"0P
" stamp over visual selected text
vnoremap S "_d"0P

" directly jump to edit mode from visual mode
vmap i <ESC>i
vmap o <ESC>o
vmap a <ESC>a
vmap A <ESC>A
" eclipse style autocompletion
" imap <C-SPACE> <C-p>
" map <C-SPACE> i<C-p>

" enable emacs-style line navigation and editing
map  <C-e> <ESC>$
imap <C-e> <ESC>A
map  <C-a> <ESC>^
imap <C-a> <ESC>^i
imap <C-k> <ESC>Di
map  <C-k> <ESC>D

" directly jump into visual block mode from insert mode
imap <C-v> <ESC><C-v>

"AlignCtrl l:
vmap <C-A> :Align=<CR> 

" Remap line-exchange commands to match TextMate's shortcuts. Thanks to vimcasts.org for this :)
" Requires vim-unimpaired
nmap <C-up> [e
nmap <C-down> ]e
vmap <C-up> [egv
vmap <C-down> ]egv
vnoremap < <gv
vnoremap > >gv

" Open line above (ctrl-shift-o much easier than ctrl-o shift-O)
"imap <C-Enter> <C-o>o
"nmap <C-Enter> o
"imap <C-S-Enter> <C-o>O
"nmap <C-S-Enter> O

" Mac-like tab navigation
map <D-S-]> gt
map <D-S-[> gT

" <Del> works, I don't see why <BS> shouldn't
map <bs> X

" ctr-delete and ctr-backspace delete the current word
imap <C-BS> <ESC>dWi
imap <C-Del> <ESC>dwi

" Create directories when saving
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p %:h" | redraw! | endif
augroup END

" UI / FONT ===============================================================
" change line the number backgrounds in insert mode
autocmd InsertEnter * highlight LineNr ctermbg=DarkBlue ctermfg=white
autocmd InsertLeave * highlight LineNr ctermbg=NONE ctermfg=None

" Remove GUI menu and toolbar
set guioptions-=T
set guioptions-=m
" share the system clipboard
set clipboard=unnamed
"set guioptions-=m
set anti guifont=Ubuntu\ Mono\ for\ Powerline\ 10   
set mouse=a

" Color scheme and tweaks
set background=light
"let g:solarized_menu=0
colorscheme solarized
highlight Cursor guibg=#ecff55 " was #eabf50
highlight NonText term=NONE ctermfg=2 ctermbg=NONE guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
highlight clear Conceal
highlight default link Conceal Statement
highlight default link qfSeparator Conceal

" =======================================================================
"
" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
function! s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      if winnr("$") == 1
        q
      endif
    endif
  endif
endfunction
autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()


" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
    let @/ = ''
    if exists('#auto_highlight')
        au! auto_highlight
        augroup! auto_highlight
        setl updatetime=4000
        echo 'Highlight current word: off'
        return 0
    else
        augroup auto_highlight
            au!
            au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
        augroup end
        setl updatetime=500
        echo 'Highlight current word: ON'
        return 1
    endif
endfunction


if has("gui_macvim")
   macmenu &File.New\ Tab key=<nop>
   map <D-t> <Plug>PeepOpen
end

" vim: set ts=4 sw=4 ts=4 :
