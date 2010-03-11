#!/bin/bash

# toggle proper error propagation, fail if one command fails
set -e

# get the current script's dir
DIR=`readlink "$0"` || DIR="$0";
DIR=`dirname "$DIR"`;
cd "$DIR"
# then use `pwd` or $DIR


