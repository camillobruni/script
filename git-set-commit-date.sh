#!/usr/bin/env bash
#
# vim: set tabstop=4 shiftwidth=4 expandtab autoindent:
#

help=$(cat << 'EOF'

Change comitter and author date of a specified commit.

Usage:

    git-set-parent.sh <commit SHA> date 

EOF
)

# ============================================================================
while getopts :h opt
do
    case $opt in
    'h')    echo "$help"
            exit 0
            ;;
      ?)    echo "invalid arg"
            echo "$help"
            exit 1
            ;;
    esac
done

# ============================================================================

"$(git rev-parse --show-toplevel)" || (echo "Could not find Git repository"; exit 1)

commit="$1"
date="$2"
target_commit=$(git rev-parse $commit)


echo "CHANGING DATE OF $target_commit TO $date"

# ============================================================================
git filter-branch \
    --force \
	--tag-name-filter "cat" \
	--env-filter \
    "if [ \$GIT_COMMIT = $commit ]
     then
         export GIT_AUTHOR_DATE=\"$date\"
         export GIT_COMMITTER_DATE=\"$date\"
     fi"
git gc