#!/usr/bin/env bash
# Author: Camillo Bruni

if { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    echo "usage: git-history-all path [path ...]
	
Script to permanently delete files/folders from your git repository. To use it, cd to your repository's root and then run the script with a list of paths
you want to delete, e.g., git-delete-history path1 path2"
    exit 0
fi

echo "Removing $@"

git filter-branch \
    --force \
    --prune-empty \
    --index-filter "git rm -rf --cached --ignore-unmatch $@" \
    --tag-name-filter "cat" \
	-- --all
