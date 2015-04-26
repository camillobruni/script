#!/usr/bin/env bash

# =============================================================================

SOURCE_DIR=`readlink "$0"` || SOURCE_DIR="$0";
SOURCE_DIR=`dirname "$DIR"`;
cd "$DIR"
SOURCE_DIR=`pwd -P`

# =============================================================================
if { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    echo "   Sets up git preferences from from  this repository:
    $SOURCE_DIR/.gitalias -> ~/.gitalias
    $SOURC_DIR/git-*.sh -> /usr/bin/local/ "
    exit 0
fi

# =============================================================================

ln -vs $SOURCE_DIR/.gitalias $HOME/
echo "Add the following to your ~/.gitconfig file to include .gitalias"
echo "[include]"
echo "    path = .gitalias"
echo ""
echo "Installing git helper scripts:"

for SCRIPT in "$SOURCE_DIR"/git*.sh; do
    SCRIPT_NAME=`basename -s .sh "$SCRIPT"`
    ln -sv $SCRIPT /usr/local/bin/"$SCRIPT_NAME"
done
