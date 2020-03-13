# System-wide .bashrc file for interactive bash(1) shells.
#set -x
#if [ -z "$PS1" ]; then
#   return
#fi

# use this for profiling the bashrc..
#PS4='+ $(date "+%s.%N")\011 '
#exec 3>&2 2>/tmp/bashstart.$$.log
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

# Make bash check its window size after a process completes
#shopt -s checkwinsize

export HISTFILESIZE=10000 # the bash history should save 3000 commands
export HISTCONTROL=ignorespace:erasedups
shopt -s histappend

# ENCODING SHIZZLE --------------------------------------------------------------

# swiss format 
export LC_MONETARY="de_CH.utf-8"
export LC_NUMERIC="de_CH.utf-8"
export LC_TIME="de_CH.utf-8"
export LC_PAPER="de_CH.UTF-8"
export LC_TELEPHONE="de_CH.UTF-8"
export LC_MEASUREMENT="de_CH.UTF-8"
export LC_ADDRESS="de_CH.UTF-8"
# for everything else we use en_US
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

# override all previous LC_* settings
# export LC_ALL="en_US.UTF-8"

# ============================================================================

export PATH=/usr/local/git/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:$PATH:/usr/local/mysql/bin
export PATH=$PATH:/opt/git-svn-clone-externals
# homebrew ruby gem path, cannot use fixed path as it would include a changing
# version number
export PATH=$PATH:$(cd $(which gem)/..; pwd)

# ============================================================================
export M2_HOME=/opt/mvn/
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

# ============================================================================

#export RUBYLIB=$RUBYLIB:/Library/Ruby/Gems/1.8/:/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8/
#export RSENSE_HOME=/opt/rsense-0.3/

#export PYTHONSTARTUP=/usr/local/bin/ipythonShell

export BROWSER=open
export EDITOR=mvim
export VISUAL=mvim
export SVN_EDITOR=mvim
export H2_EDITOR=mvim

export MANPATH=/opt/local/share/man:$MANPATH

export PYTHON_VERSION=2.7
export PYTHONIOENCODING=UTF-8
export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH

export IRBRC='~/.irbrc'

if [ -f `brew --prefix`/etc/bash_completion ]; then
    BASH_COMPLETION_DIR=~/.bash_completion.d #manually set the local bash_completion dir
    export BASH_COMPLETION BASH_COMPLETION_DIR
    . $(brew --prefix)/etc/bash_completion
    . $(brew --repository)/Library/Contributions/brew_bash_completion.sh
fi

export GOPATH=$HOME/.gocode
export PATH=$PATH:$GOPATH/bin

# Python =====================================================================

# manually add DYLD path for python mysql gagu
#export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH
#export VIRTUALENVWRAPPER_PYTHON=/Library/Frameworks/Python.framework/Versions/2.7/bin/python
export WORKON_HOME=~/.virtualenv
#export PIP_REQUIRE_VIRTUALENV=true
#export PIP_VIRTUALENV_BASE=$WORKON_HOME

# enable this if virtualenvs are used
source /usr/local/bin/virtualenvwrapper.sh

# ============================================================================
# colorize ls ouputs
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# ============================================================================
alias g='git'
complete -o default -o nospace -F _git g

alias o='_open'
alias oi='_open' #placeholder to trigger bash-completion
alias oo='open "`path`"'
alias f='find . -name '
alias p1='_ping1'
alias l='ls -l'
alias ll='ls -al'
alias du='du -h'
alias cdup='cd ..'
alias ping1='ping -c 1'
alias scn='svn'
alias irb='irb -rubygems'
alias path='/Applications/path.app/Contents/MacOS/path'
alias cdp='cd "`path`"'
alias tre='tree | less'
alias 3='tree | less'
alias t='trex'
alias j='_jump'
hash hub && alias git='hub'
alias password='apg -a1 -m20'

alias chrome='/Applications/Chrome.app/Contents/MacOS/Google\ Chrome'

alias ssh='ssh -C'
alias sshprox='ssh -CND 8888 '

alias x11='DISPLAY = :0.0;export DISPLAY;'

#alias grep='grep -n --color=auto'
alias rgrep='grep -r -n --color=auto'

alias tvim='vim -c "NERDTree" -c "wincmd p"'
alias mvim='mvim  -c "NERDTree" -c "wincmd p"'

alias svndiff='svn diff "${@}" | colordiff | lv -c'
alias svnlog='svn log --verbose | less'

#alias irb='irb1.9 -r "irb/completion"'

# better output
alias contacts="contacts -lHf '%n %p %mp %e %a'"
alias contact='contacts'
alias calendar='icalBuddy'

#alias prox='export http_proxy=http://proxy:80/'
#alias unprox='unset http_proxy'


# pman opens man pages in preview / skim ====================================
pman() {
    man -t "$@" | open -f -a Skim
}

# open which opens the current dir if no arg is specified ===================
_open()
{
    if [[ $# -eq 0 ]]; then
        open .;
        return $?;
    fi    
    open "$*";
}

# ping google or the provided argument once =================================
_ping1()
{
    if [[ $# -eq 0 ]]; then
        ping -c 1 www.google.com
        return $?;
    fi    
    ping -c 1 "$*";
}

# a small single line evaluator for ruby ====================================
rruby()
{
    ruby -e "puts $*"
}
alias c=rruby

# open google search results from the command line ==========================
google()
{
    QUERY=`echo "$*" | perl -MURI::Escape -ne 'print uri_escape($_)'`
    open "https://encrypted.google.com/search?q=$QUERY"
}
alias ggl=google

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

# ============================================================================
# load https://github.com/rupa/z after redefinition of cd
export _Z_DATA="$HOME/.z/"
source `brew --prefix`/etc/profile.d/z.sh

function _jump {
	# first try `jump` with all the options then `z` (auto tracker)
	jump $* || z $*
}

# ============================================================================

# Prompt: requires git and svn
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[git:\1] /'
}

export T_TIME_HEADER=1
time_header() {
    COL_SUBS=`printf "%*s" $(( $COLUMNS - 2))`
    #test $((`date +%s` - $T_TIME_HEADER)) -gt 2 && (echo  ✂ ${COL_SUBS// /-});
    echo  ✂ ${COL_SUBS// /—};
}

function last_return_status() {
    EXIT_STATUS="$?";
    if [[ $EXIT_STATUS != "0" ]]; then 
        printf "$RED  ☛  %s$NO_COLOR\n" $EXIT_STATUS
    fi
}

function __git_ps1() {
    echo "";
}

export PS1="\$(__git_ps1)\[$YELLOW\]\W\[$NO_COLOR\]: "
export PROMPT_COMMAND="last_return_status; time_header; T_TIME_HEADER=\`date +%s\`;$PROMPT_COMMAND"

# ============================================================================
