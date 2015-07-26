#!/bin/bash

# System Variables
user=$(whoami)
hostname=$(hostname | sed 's/.local//g')

# OS Version
if hash sw_vers 2>&-; then
    versionNumber=$(sw_vers -productVersion) # Finds version number
    versionMajor=`echo $versionNumber | cut -d'.' -f1`
    versionMinor=`echo $versionNumber | cut -d'.' -f2`
    versionShort="${versionMajor}.${versionMinor}"
    case $versionShort in
    10.10)
        versionString="Yosemite"
        ;;
    10.9)
        versionString="Mavericks"
        ;;
    10.8)
        versionString="Mountain Lion"
        ;;
    10.7)
        versionString="Lion"
        ;;
    10.6)
        versionString="Snow Leopard"
        ;;
    10.5)
        versionString="Leopard"
        ;;
    10.4)
        versionString="Tiger"
        ;;
    10.3)
        versionString="Panther"
        ;;
    10.2)
        versionString="Jaguar"
        ;;
    10.1)
        versionString="Puma"
        ;;
    10.0)
        versionString="Cheetah"
        ;;
    esac
    distro="OS X $(sw_vers -productVersion) $(versionString)"
else
    distro=`lsb_release -a 2>&- | grep Description | awk '{$1=""; print $0}'`
fi
kernel="$(uname) $(uname -r)"
uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
shell="$SHELL"
terminal="$TERM"
cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
if [[ -z "$cpu" ]]; then
  cpu_count=$(cat /proc/cpuinfo | grep "model name" | wc -l)
  cpu_model=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f2)
  cpu="$cpu_model x $cpu_count"
fi
 
load=$(uptime | sed 's/.*\: \(.*\)/\1/')
packagehandler=""

# removes (R) and (TM) from the CPU name so it fits in a standard 80 window
cpu=$(echo "$cpu" | awk '$1=$1' | sed 's/([A-Z]\{1,2\})//g')
mem=$(sysctl -n hw.memsize 2>/dev/null)
ram="$((mem/1073741824)) GB"
if [[ -z "$mem" ]]; then
  mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  ram="$((mem/1024/1024)) GB"
fi
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

## en1 or en0 should contain the ip address
if hash ipconfig 2>&-; then
    ipAddress=`ipconfig getifaddr en1`
    if [ -z "$ipAddress" ]; then
        ipAddress=`ipconfig getifaddr en0`
    fi
else
  ipAddress=$(hostname -i)
fi

userText="${textColor}User:${normal}"
hostnameText="${textColor}Hostname:${normal}"
hostIpText="${textColor}IP:${normal}"
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
print "        ░▒███████████████████░         $distroText$distro"
print "       ████████████████████████░       $kernelText $kernel"
print "      ▓████▓▒░░        ░▒▓██████       $uptimeText $uptime"
print "     ░████░              ▒█████▒       $shellText $shell"
print "     ▒████                ▓█████░      $terminalText $terminal"
print "      ████░               ▓█████░      $packagehandlerText $packagehandler"
print "      ░███▒               ▒ ███░       $cpuText $cpu"
print "       ▒██▒               ░████        $memoryText $ram"
print "        ░██▒              ░███         $diskText $disk"
print "          ░█▓             ██           $loadText $load"
print "           ██            ▓█            $hostIpText $ipAddress ${normal}"
print ""
print ""
