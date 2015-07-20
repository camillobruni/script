#!/bin/bash

# System Variables
user=$(whoami)
hostname=$(hostname | sed 's/.local//g')
if hash sw_vers 2>&-; then
	distro="OS X $(sw_vers -productVersion)"
else
	distro=`lsb_release -a 2>&- | grep Description`
fi
kernel=$(uname)
uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
shell="$SHELL"
terminal="$TERM"
cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null) 
load=$(uptime | sed 's/.*\: \(.*\)/\1/')
packagehandler=""

# removes (R) and (TM) from the CPU name so it fits in a standard 80 window

cpu=$(echo "$cpu" | awk '$1=$1' | sed 's/([A-Z]\{1,2\})//g')

mem=$(sysctl -n hw.memsize 2>/dev/null)
ram="$((mem/1073741824)) GB"
disk=`df | head -2 | tail -1 | awk '{print $5}'`

# Colors Variables
red="1"
green="2"
yellow="3"
blue="4"
purple="5"
lightblue="6"
grey="7"

textColor=$(tput setaf $lightblue)
normal=$(tput sgr0)

# Add a -c option to enable classic color logo
if [[ $1 == "-c" ]] || [[ $1 == "--color" ]] || [[ $2 == "-c" ]] || [[ $2 == "--color" ]]; then
  GREEN='\033[00;32m'
  YELLOW='\033[00;33m'
  LRED='\033[01;31m'
  RED='\033[00;31m'
  PURPLE='\033[00;35m'
  CYAN='\033[00;36m'
  BLUE='\033[00;34m'
  ORANGE='\033[38;5;220m'
fi

# Add a -m command to switch to macports or default to brew
if [[ $1 == "-m" ]] || [[ $1 == "--macports" ]] || [[ $2 == "-m" ]] || [[ $2 == "--macports" ]]
then	
	packagehandler="`port installed | wc -l | awk '{print $1 }'`"
else
	if hash brew 2>&-; then
		packagehandler="`brew list -l | wc -l | awk '{print $1 }'` formulas"
	else
		packagehandler=`dpkg -l | wc -l | awk '{print $1 }'`
	fi
fi

userText="${textColor}User:${normal}"


hostnameText="${textColor}Hostname:${normal}"
distroText="${textColor}Distro:${normal}"
kernelText="${textColor}Kernel:${normal}"
uptimeText="${textColor}Uptime:${normal}"
loadText="${textColor}Load:${normal}"
shellText="${textColor}Shell:${normal}"
terminalText="${textColor}Terminal:${normal}"
packagehandlerText="${textColor}Packages:${normal}"
cpuText="${textColor}CPU:${normal}"
memoryText="${textColor}Memory:${normal}"
diskText="${textColor}Disk:${normal}"


print() {
	echo -e "$ORANGE$1"
	sleep 0.001
}


print ""
print ""
print "              ░▓███████▒░              $userText $user"
print "          ░▒█████████████▓▒░           $hostnameText $hostname"
print "        ░▒███████████████████░         $distroText $distro"
print "       ████████████████████████░       $kernelText $kernel"
print "      ▓████▓▒░░        ░▒▓██████       $uptimeText $uptime"
print "     ░████░              ▒█████▒       $shellText $shell"
print "     ▒████                ▓█████░      $terminalText $terminal"
print "      ████░               ▓█████░      $packagehandlerText $packagehandler"
print "      ░███▒               ▒ ███░       $cpuText $cpu"
print "       ▒██▒               ░████        $memoryText $ram"
print "        ░██▒              ░███         $diskText $disk"
print "          ░█▓             ██           $loadText $load"
print "           ██            ▓█ ${normal}"
print ""
print ""
