#!/usr/bin/env bash

# =============================================================================

SOURCE_DIR=`readlink "$0"` || SOURCE_DIR="$0";
SOURCE_DIR=`dirname "$DIR"`;
cd "$DIR"
SOURCE_DIR=`pwd -P`

# =============================================================================
if { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    echo "   Install shell scripts from from  this repository"
    exit 0
fi

# =============================================================================

ln -sv $SOURCE_DIR/ack.pl /usr/local/bin/ack
ln -sv $SOURCE_DIR/archey.sh /usr/local/bin/archey
ln -sv $SOURCE_DIR/cd_func.sh /usr/local/bin/cd_func
ln -sv $SOURCE_DIR/h2.rb /usr/local/bin/h2
ln -sv $SOURCE_DIR/h2Source.txt ~/.h2
ln -sv $SOURCE_DIR/sbb.rb /usr/local/bin/sbb
ln -sv $SOURCE_DIR/todo.rb /usr/local/bin/todo
ln -sv $SOURCE_DIR/translate.rb /usr/local/bin/translate
ln -sv $SOURCE_DIR/average.rb /usr/local/bin/average
