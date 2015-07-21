set nocompatible
filetype off " required

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

command! PluginUpdate PluginInstall!

" let Vundle manage Vundle
Plugin 'gmarik/vundle'

" UI improvements
Plugin 'Lokaltog/vim-powerline'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'nathanaelkane/vim-indent-guides'

" Plugin 'altercation/vim-colors-solarized'
Plugin 'cdlm/vim-colors-solarized'

" Language modes
Plugin 'vim-pandoc/vim-pandoc'
Plugin 'hallison/vim-markdown'
Plugin 'vim-pandoc/vim-markdownfootnotes'
Plugin 'skammer/vim-css-color'
Plugin 'tpope/vim-haml'
Plugin 'tpope/vim-rake'
Plugin 'vim-ruby/vim-ruby'
Plugin 'postmodern/vim-yard'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'Valloric/YouCompleteMe' 

" Editing
Plugin 'matchit.zip'
Plugin 'ervandew/supertab'
Plugin 'sickill/vim-pasta'
Plugin 'godlygeek/tabular'
Plugin 'Raimondi/delimitMate'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'Gundo'
Plugin 'Align'
'
" snipmate & deps
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'rbonvall/snipmate-snippets-bib'

" External tools
Plugin 'hallettj/jslint.vim'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-fugitive'


call vundle#end()

filetype plugin indent on
