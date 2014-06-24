# System-wide .zshrc file for interactive zsh(1) shells.
if [ -z "$PS1" ]; then
   return
fi

skip_global_compinit=1

ZSH=$HOME/.oh-my-zsh

ZSH_THEME="cami"
plugins=(git git-hubflow web-search brew textmate osx rsync zsh-syntax-highlighting oi gem dircycle virtualenvwrapper)

source $ZSH/oh-my-zsh.sh

if hash brew 2>/dev/null; then
	fpath=(`brew --prefix`/share/zsh-completions $fpath);
fi

ZSH_COMPLETION_DIR=~/.zsh_completion.d #manually set the local bash_completion dir

ZSH_THEME_LAST_PRINT_DATE=0

# ============================================================================
# display system information on startup

(archey -c &) 2> /dev/null 

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

export HISTFILESIZE=10000 # the bash history should save 10000 commands
export HISTCONTROL=ignorespace

# ENCODING SHIZZLE --------------------------------------------------------------

# swiss format 
export LC_MONETARY="de_CH.UTF-8"
export LC_NUMERIC="de_CH.UTF-8"
export LC_TIME="de_CH.UTF-8"
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

export PATH=/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:$PATH
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/opt/git-svn-clone-externals
# homebrew ruby gem path, cannot use fixed path as it would include a changing
# version number

if hash brew 2>/dev/null; then
    export PATH=$PATH:$(cd $(which gem)/..; pwd)
fi

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
export GIT_EDITOR="vim -c 'startinsert'"
export VISUAL=mvim
export SVN_EDITOR=mvim
export H2_EDITOR=mvim

export MANPATH=/opt/local/share/man:$MANPATH

export PYTHON_VERSION=2.7
#export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH

export IRBRC='~/.irbrc'

# Python =====================================================================

# manually add DYLD path for python mysql gagu
#export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH
#export VIRTUALENVWRAPPER_PYTHON=/Library/Frameworks/Python.framework/Versions/2.7/bin/python
#export WORKON_HOME=~/.virtualenv
#source /usr/local/bin/virtualenvwrapper.sh
#export PIP_REQUIRE_VIRTUALENV=true
#export PIP_VIRTUALENV_BASE=$WORKON_HOME
export VIRTUAL_ENV_DISABLE_PROMPT=true

# ============================================================================
# better output
#alias grep='grep -n --color=auto'
#alias irb='irb1.9 -r "irb/completion"'
#alias prox='export http_proxy=http://proxy:80/'
#alias unprox='unset http_proxy'
alias 3='tree | less'
alias calendar='icalBuddy'
alias cdp='cd "`path`"'
alias cdup='cd ..'
alias chrome='/Applications/Chrome.app/Contents/MacOS/Google\ Chrome'
alias contact='contacts'
alias contacts="contacts -lHf '%n %p %mp %e %a'"
alias du='du -h'
alias f='find . -name '
alias find-name="find . -name "
alias fname="find-name"
alias g='git'
alias imdb='web_search duckduckgo \!imdb'
alias irb='irb -rubygems'
alias l='ls -l'
alias ll='ls -Aflhp'
alias mvim='mvim  -c "NERDTree" -c "wincmd p"'
alias o='_open'
alias oi='_open' #placeholder to trigger bash-completion
alias oo='open "`path`"'
alias p1='_ping1'
alias password='apg -a1 -m80 -n10'
alias path='/Applications/path.app/Contents/MacOS/path'
alias ping1='ping -c 1'
alias rgrep='grep -r -n --color=auto'
alias scn='svn'
alias t='trex'
alias tre='tree | less'
alias v.add2virtualenv='add2virtualenv'
alias v.cd='cdvirtualenv'
alias v.project='cdproject'
alias v.cdsitepackages='cdsitepackages'
alias v.deactivate='deactivate'
alias v.lssitepackages='lssitepackages'
alias v.mk='mkvirtualenv'
alias v.rm='rmvirtualenv'
alias v.switch='workon'
alias v='workon'

function git(){ hub $@ }


alias chrome='/Applications/Chrome.app/Contents/MacOS/Google\ Chrome'

alias ssh='ssh -C'
alias sshprox='ssh -CND 8888 '
alias svndiff='svn diff "${@}" | colordiff | lv -c'
alias svnlog='svn log --verbose | less'
alias rm='trash'
alias rrm='rm'
alias t='trex'
alias tre='tree | less'
alias tvim='vim -c "NERDTree" -c "wincmd p"'
alias x11='DISPLAY = :0.0;export DISPLAY;'

function git(){ hub $@ }


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
ggl()
{
    QUERY=`echo "$*" | perl -MURI::Escape -ne 'print uri_escape($_)'`
    open "https://encrypted.google.com/search?q=$QUERY"
}

# ============================================================================
# load https://github.com/rupa/z after redefinition of cd
export _Z_DATA="$HOME/.z/"

source `jump-bin --zsh-integration`
if hash brew 2>/dev/null; then
	[[ -s `brew --prefix`/etc/autojump.zsh ]] && . `brew --prefix`/etc/autojump.zsh
fi

function _jump {
	# first try `jump` with all the options then autojump
	jump $* 2&>> /dev/null || cd `autojump $*` || ( echo "'$*' not found" && exit 1)
}
alias j=_jump

# =============================================================================
# wait for any background processes launched in the setup file
wait
