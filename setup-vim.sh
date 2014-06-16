#/usr/bin/bash

SOURCE_DIR=`readlink "$0"` || SOURCE_DIR="$0";
SOURCE_DIR=`dirname "$DIR"`;
cd "$DIR"
SOURCE_DIR=`pwd -P`

# =============================================================================
if { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    echo "    Sets up the vim preferences in your home directory from the 
    .vim directory in this repository:
    $SOURCE_DIR/.vimrc -> ~/.vimrc
    $SOURCE_DIR/.vim/ -> ~/.vim/"
    exit 0
fi

# =============================================================================

ln -vs $SOURCE_DIR/.vim $HOME/
ln -vs $HOME/.vim/.vimrc $HOME/
mkdir $HOME/.vim-undo

$HOME/.vim/vundle-install.sh
