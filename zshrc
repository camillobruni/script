# System-wide .zshrc file for interactive zsh(1) shells.
#if [ -z "$PS1" ]; then
#   return
#fi
TMP_OS=`uname | tr "[:upper:]" "[:lower:]"`
if [[ "{$TMP_OS}" = *darwin* ]]; then
    OS="mac";
elif [[ "{$TMP_OS}" = *linux* ]]; then
    OS="linux";
elif [[ "{$TMP_OS}" = *win* ]]; then
    OS="win";
elif [[ "{$TMP_OS}" = *mingw* ]]; then
    OS="win";
fi

export TERM='xterm-256color' 


skip_global_compinit=1

ZSH=$HOME/.oh-my-zsh

ZSH_THEME="cami"
plugins=(git git-hubflow rsync zsh-syntax-highlighting oi gem dircycle autojump)

source $ZSH/oh-my-zsh.sh

if hash brew 2>/dev/null; then
	fpath=(`brew --prefix`/share/zsh-completions $fpath);
fi

ZSH_COMPLETION_DIR=~/.zsh_completion.d #manually set the local bash_completion dir

ZSH_THEME_LAST_PRINT_DATE=0

# enable comments on the REPL
setopt interactivecomments
# don't directly jump to dirs in order to prevent completion of all usernames
unsetopt cdablevars
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

export PYTHONIOENCODING=UTF-8

# ============================================================================
if [[ "$OS" == "mac" ]]; then
    export EDITOR=vim
    export MANPATH=/opt/local/share/man:$MANPATH
    export OPEN_CMD=open
    export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.4/bin
    export PATH=/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:$PATH
    # homebrew ruby gem path, cannot use fixed path as it would include a changing
    # version number
    if hash brew 2>/dev/null; then
        export PATH=$PATH:$(cd $(which gem)/..; pwd)
    fi
else
    export EDITOR=vim
    export OPEN_CMD=gnome-open
fi

export BROWSER=$OPEN_CMD
export GIT_EDITOR="vim -c 'startinsert'"
export VISUAL=$EDITOR
export SVN_EDITOR=$EDITOR
export H2_EDITOR=$EDITOR

export PYTHON_VERSION=3.4

export IRBRC='~/.irbrc'

# Python =====================================================================

# manually add DYLD path for python mysql gagu
#export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH
#export VIRTUALENVWRAPPER_PYTHON=/Library/Frameworks/Python.framework/Versions/2.7/bin/python
export WORKON_HOME=~/.virtualenv
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
alias gr="git grep"
alias 3='tree | less'
alias calendar='icalBuddy'
alias cdp='cd "`path`"'
alias cdup='cd ..'
# alias chrome='/Applications/Chrome.app/Contents/MacOS/Google\ Chrome'
alias contact='contacts'
alias contacts="contacts -lHf '%n %p %mp %e %a'"
alias du='du -h'
alias f='fab'
alias find-name="find . -name "
alias fname="find-name"
alias g='git'
alias gitk='gitk --all &'
alias htop='sudo htop'
alias imdb='web_search duckduckgo \!imdb'
alias irb='irb -rubygems'
alias l='ls -l'
alias ll='ls -Aflhp'
alias log='/Users/Shared/log/log.rb'
alias m='v.project && ./manage.py '
alias mvim='mvim  -c "NERDTree" -c "wincmd p"'
alias make_targets="make -qp | awk -F':' '/^[a-zA-Z0-9][^\$#\/\t=]*:([^=]|$)/ {split(\$1,A,/ /); for(i in A) print A[i]}'"
alias o='_open'
alias oi='_open' #placeholder to trigger bash-completion
alias oo='$OPEN_CMD "`path`"'
alias p='pip'
alias p1='_ping1'
alias password='apg -a1 -m80 -n10'
alias path='/Applications/path.app/Contents/MacOS/path'
alias ping1='ping -c 1'
alias rgrep='grep -r -n --color=auto'
if [[ "$OS" == 'mac' ]]; then
    alias rrm='rm'
    alias rm='trash'
fi
alias scn='svn'
alias sp='v.project && ./manage.py shell_plus'
alias ssh='ssh -C'
alias sshprox='ssh -CND 8888 '
alias svndiff='svn diff "${@}" | colordiff | lv -c'
alias svnlog='svn log --verbose | less'
alias t='trex'
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'
alias wpr-replay="~/chromium/src/third_party/webpagereplay/replay.py --no-dns_forwarding --use_closest_match --port=4080 --ssl_port=4443"
alias tre='tree | less'
alias tvim='vim -c "NERDTree" -c "wincmd p"'
alias v.add2virtualenv='add2virtualenv'
alias v.cd='cdvirtualenv'
alias v.cdsitepackages='cdsitepackages'
alias v.deactivate='deactivate'
alias v.lssitepackages='lssitepackages'
alias v.mk='mkvirtualenv'
alias v.project='cdproject'
alias v.rm='rmvirtualenv'
alias v.switch='workon'
alias v='workon'
alias vless='vim -u /usr/share/vim/vim71/macros/less.vim'
alias webserver="python -m SimpleHTTPServer"
alias x11='DISPLAY = :0.0;export DISPLAY;'

if hash hub 2>/dev/null; then
    function git(){ hub $@ }
fi


# pman opens man pages in preview / skim ====================================
pman() {
    man -t "$@" | open -f -a Skim
}

# open which opens the current dir if no arg is specified ===================
_open()
{
    if [[ $# -eq 0 ]]; then
         $OPEN_CMD .;
        return $?;
    fi
    $OPEN_CMD "$*";
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

# print the average of a file containing a number per line ==================

file_avg() {
    ruby -e "arr=File.readlines('$1').map{|l|l.chomp.to_f};puts(arr.inject(0.0) { |sum, el| sum + el } / arr.size)"
}

# open google search results from the command line ==========================
ggl()
{
    QUERY=`echo "$*" | perl -MURI::Escape -ne 'print uri_escape($_)'`
    open "https://encrypted.google.com/search?q=$QUERY"
}

# only open a single instance of gvim by default
gvim () {
    command gvim --remote-silent "$@" || command gvim "$@";
}
# ============================================================================
# Directory stack extensions
setopt autopushd pushdminus pushdsilent pushdtohome
DIRSTACKSIZE=16
DIRSTACKFILE=~/.zdirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1] && cd $OLDPWD
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

# ============================================================================
# load https://github.com/rupa/z after redefinition of cd
export _Z_DATA="$HOME/.z/"

source `jump-bin --zsh-integration`
if hash brew 2>/dev/null; then
    [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && \
        . $(brew --prefix)/etc/profile.d/autojump.sh
fi

function _autojump_jump {
	# first try `jump` with all the options then autojump
	jump $* 2&>> /dev/null || \
        cd "`autojump $*`" || \
        (echo "'$*' not found" && exit 1)
}
alias j=_autojump_jump

# =============================================================================
# helper
function rel_path() {
    python -c "import os.path; print os.path.relpath('${1}', '${2}')"
}

function format-js() {
    TMP=`mktemp`
    IN=$1
    cp $IN $TMP
    js-beautify --indent-size=2 --end-with-newline $TMP > $IN
}

# wait for any background processes launched in the setup file
wait
