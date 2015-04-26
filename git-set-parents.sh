#!/usr/bin/env bash

set -e
help=$(cat << 'EOF'

Change parent to a specific commit.

Usage:

    git-set-parent.sh [-c <commit SHA>] <parent SHA>... 

Options:

    -b Branch to be filtered on
EOF
)

# ============================================================================
all=True
custom_commit=FALSE
while getopts :b:c:h opt
do
    case $opt in
#    'b')    branch=$OPTARG; all=FALSE
#            ;;
    'c')    commit=$OPTARG; custom_commit=True
            ;;
    'h')    echo "$help"
            exit 0
            ;;
      ?)    echo "invalid arg"
            echo "$help"
            exit 1
            ;;
    esac
done

# remove the processed options
shift $(($OPTIND - 1))

# ============================================================================

grafts="$(git rev-parse --show-toplevel)/.git/info/grafts" \
	|| (echo "Could not find Git repository"; exit 1)

if [ -n "$custom_commit" ]; then
	target_commit=$(git rev-parse $commit)
else
	target_commit=$(git rev-parse HEAD)
fi

parent_commits=`for parent_commit in $*; do echo -n " $(git rev-parse $parent_commit)"; done`

echo "CHANGING PARENTS OF $target_commit TO $parent_commits"

echo "$target_commit$parent_commits" > $grafts

# ============================================================================
[ -n "$all" ]    && range='-- --all' || range='HEAD'
[ -n "$branch" ] && range="$branch"

# ============================================================================
git filter-branch \
    --force \
	--tag-name-filter "cat" \
    $range

rm $grafts
