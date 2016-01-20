set nocompatible
filetype off " required

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

command! PluginUpdate PluginInstall!

" let Vundle manage Vundle
Plugin 'gmarik/vundle'

" UI improvements
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
" allow insert vs. block cursor
" Plugin 'jszakmeister/vim-togglecursor'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
" Plugin 'scrooloose/nerdcommenter'
Plugin 'nathanaelkane/vim-indent-guides'

" Plugin 'altercation/vim-colors-solarized'
Plugin 'cdlm/vim-colors-solarized'

" Language modes
" Plugin 'vim-pandoc/vim-pandoc'
Plugin 'hallison/vim-markdown'
" Plugin 'vim-pandoc/vim-markdownfootnotes'
" Plugin 'skammer/vim-css-color'
" Plugin 'tpope/vim-haml'
Plugin 'vim-ruby/vim-ruby'
" Plugin 'postmodern/vim-yard'
" Plugin 'octol/vim-cpp-enhanced-highlight'
" fast file opening
Plugin 'kien/ctrlp.vim'

" COMPLETION
Plugin 'Valloric/YouCompleteMe'
" Use Supertab for ycm and snipmate compatibility
Plugin 'ervandew/supertab'

" Editing
Plugin 'sickill/vim-pasta'
Plugin 'godlygeek/tabular'
" Plugin 'Raimondi/delimitMate'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
" symmetric commands that make sense
Plugin 'tpope/vim-unimpaired'
" file/project navigation
Plugin 'tpope/vim-vinegar'
Plugin 'Gundo'
Plugin 'Align'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

" External tools
Plugin 'mileszs/ack.vim'
" same but for ag instead ack
Plugin 'rking/ag.vim'
Plugin 'tpope/vim-fugitive'

call vundle#end()

filetype plugin indent on
