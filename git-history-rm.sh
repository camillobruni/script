#!/bin/bash
echo "Removing $@"

git filter-branch \
    --force \
    --prune-empty \
    --index-filter "git rm -rf --cached --ignore-unmatch $@" \
    --tag-name-filter "cat" \
	-- --all
