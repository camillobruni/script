#!/usr/bin/env bash

# =============================================================================

SOURCE_DIR=`readlink "$0"` || SOURCE_DIR="$0";
SOURCE_DIR=`dirname "$DIR"`;
cd "$DIR"
SOURCE_DIR=`pwd -P`

# =============================================================================
if { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    echo "   Sets up ruby preferences from from this repository:
    $SOURCE_DIR/.irbrc -> ~/.irbrc"
    exit 0
fi

# =============================================================================

ln -vs $SOURCE_DIR/.irbrc $HOME/
echo ""
echo "Installing default ruby gems:"

for gem in hub colorize lolcat jump wirble what_methods map_by_method; do
	echo 'Installing: ' $gem;
	gem install -V $gem;
done
