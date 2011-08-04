# System-wide .bashrc file for interactive bash(1) shells.
if [ -z "$PS1" ]; then
   return
fi

# ============================================================================

# Colors from http://wiki.archlinux.org/index.php/Color_Bash_Prompt
# Misc
NO_COLOR='\e[0m' #disable any colors
# Regular colors
  BLACK='\e[0;30m'
    RED='\e[0;31m'
  GREEN='\e[0;32m'
 YELLOW='\e[0;33m'
   BLUE='\e[0;34m'
MAGENTA='\e[0;35m'
   CYAN='\e[0;36m'
  WHITE='\e[0;37m'
# Emphasized (bolded) colors
  EBLACK='\e[1;30m'
    ERED='\e[1;31m'
  EGREEN='\e[1;32m'
 EYELLOW='\e[1;33m'
   EBLUE='\e[1;34m'
EMAGENTA='\e[1;35m'
   ECYAN='\e[1;36m'
  EWHITE='\e[1;37m'
# Underlined colors
  UBLACK='\e[4;30m'
    URED='\e[4;31m'
  UGREEN='\e[4;32m'
 UYELLOW='\e[4;33m'
   UBLUE='\e[4;34m'
UMAGENTA='\e[4;35m'
   UCYAN='\e[4;36m'
  UWHITE='\e[4;37m'
# Background colors
  BBLACK='\e[40m'
    BRED='\e[41m'
  BGREEN='\e[42m'
 BYELLOW='\e[43m'
   BBLUE='\e[44m'
BMAGENTA='\e[45m'
   BCYAN='\e[46m'
  BWHITE='\e[47m'

# ============================================================================

export TERM=linux

# Make bash check its window size after a process completes
shopt -s checkwinsize

export HISTFILESIZE=10000 # the bash history should save 3000 commands
export HISTCONTROL=ignorespace:erasedups
shopt -s histappend

# ENCODING SHIZZLE --------------------------------------------------------------
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_COLLATE=C
export LC_MESSAGES="en_US.UTF-8"
# numbers and money in swiss format 
export LC_MONETARY="de_CH.utf-8"
export LC_NUMERIC="de_CH.utf-8"
export LC_TIME="de_CH.utf-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

# ============================================================================

# Prompt: requires git and svn
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[git:\1] /'
}

export T_TIME_HEADER=1
time_header() {
    COL_SUBS=`printf "%*s" $(( $COLUMNS - 2))`
    #test $((`date +%s` - $T_TIME_HEADER)) -gt 2 && (echo  ✂ ${COL_SUBS// /-});
    echo  ✂ ${COL_SUBS// /-};
}

function last_return_status() {
    EXIT_STATUS="$?";
    if [[ $EXIT_STATUS != "0" ]]; then 
        printf "$RED  ☛  %s$NO_COLOR\n" $EXIT_STATUS
    fi
}

export PROMPT_COMMAND="last_return_status; time_header; T_TIME_HEADER=\`date +%s\`"
export PS1="\$(parse_git_branch)\[$EBLACK\]\W\[$NO_COLOR\]: "

# ============================================================================

export PATH=/usr/local/git/bin/:$PATH:/usr/local/mysql/bin/
export PATH=$PATH:/opt/subversion/bin/:/opt/local/bin:/opt/local/sbin/
export PATH=$PATH:/opt/git-svn-clone-externals/
export PATH=$PATH:/opt/llvm-gcc-4.2-2.7-x86_64-apple-darwin10/bin/
export PATH=/Library/Frameworks/Python.framework/Versions/2.6/bin:$PATH

# ============================================================================

export EDITOR=vim
export SVN_EDITOR=vim

export H2_EDITOR=mvim
export MANPATH=/opt/local/share/man:$MANPATH

export PYTHON_VERSION=2.7

if [ -f /opt/local/etc/bash_completion ]; then
     . /opt/local/etc/bash_completion
fi

#xset b off;

# ============================================================================
# colorize ls ouputs
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# ============================================================================
alias l='ls -l'
alias ll='ls -al'
alias du='du -h'
alias cdup='cd ..'
alias ping1='ping -c 1'
alias scn='svn'
alias irb='irb -rubygems'
alias path='/Applications/path.app/Contents/MacOS/path'
alias cdp='cd "`path`"'
alias tre='tree'
alias o='open .'
alias cdesktop='cd ~/Desktop/'

alias chrome='sudo -u flex /Applications/Chrome.app/Contents/MacOS/Google\ Chrome &'

alias ssh='ssh -C'
alias x11='DISPLAY = :0.0;export DISPLAY;'

alias grep='grep -n --color=auto'
alias rgrep='grep -r -n --color=auto'

alias tvim='vim -c "NERDTree" -c "wincmd p"'
alias mvim='mvim  -c "NERDTree" -c "wincmd p"'

alias svndiff='svn diff "${@}" | colordiff | lv -c'
alias svnlog='svn log --verbose | less'

alias lv='lv -c '

alias prox='export http_proxy=http://proxy:80/'
alias unprox='unset http_proxy'

# enable command line vi mode
#set -o vi
#bind "\C-a":beginning-of-line
#bind "\C-e":end-of-line
#bind "\C-k":kill-line

# cd with history ===========================================================
# acd_func 1.0.5, 10-nov-2004
# petar marinov, http:/geocities.com/h2428, this is public domain

cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

alias cd=cd_func

#if [[ $BASH_VERSION > "2.05a" ]]; then
#  # ctrl+w shows the menu
#  bind -x "\"\C-w\":cd_func -- ;"
#fi
