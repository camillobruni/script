#!/usr/bin/env ruby

`date`

require 'fileutils'

def help
    $stderr.puts "    usage /.image issueNumber"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"
end

if $*.size != 1
    help
    exit 1
end

issueNumber = $*[0]

# ===========================================================================

version  = '1.4'
tmp      = `mktemp -d -t pharo`.chomp

imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"
artifact = "Pharo#{version}"
name = "Pharo-#{version}"
path = "/Users/benjamin/Images/Monkeys"
destination = "#{path}/Monkey#{issueNumber}"
vmPath = "/Users/benjamin/Images/StackVM.app/Contents/MacOS/StackVM"

# ===========================================================================


def editor()
    if ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'vim'
    end
end

if $*[0] == "--help" || $*[0] == "-h"
    help()
    exit 0
elsif $*[0] == "--hack"
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
    exec("#{editor()} #{sourceFile}")
end





puts "fetching the latest image"

`cd "#{path}" && wget --tries=2 --timeout=3 --no-check-certificate "#{imageUrl}" --output-document="artifact#{issueNumber}.zip" && cp "#{path}/artifact#{issueNumber}.zip" "#{path}/backup.zip"  || cp "#{path}/backup.zip" "#{path}/artifact#{issueNumber}.zip"`

puts "Unzipping the archive"
`unzip -x "#{path}/artifact#{issueNumber}.zip" -d "#{destination}"`
`cd "#{destination}" && mv "#{name}/#{name}.image" "Monkey#{issueNumber}.image" ; mv "#{name}/#{name}.changes" "Monkey#{issueNumber}.changes" ; mv "#{name}/PharoV10.sources" PharoV10.sources`

puts "Cleanup"
`rm "#{path}/artifact#{issueNumber}.zip"`
`rm -rf "#{tmp}"`

# ===========================================================================

File.open("#{destination}/issueLoading.st", 'w') {|f| 
    f.puts <<IDENTIFIER

| tracker issue |

World submorphs do: [:each | each delete ].

Smalltalk garbageCollect.
Smalltalk garbageCollect.
Smalltalk garbageCollect.

Author fullName: 'MonkeyGalactikalIntegrator'.

Gofer new
	url: 'http://ss3.gemstone.com/ss/ci';
	package: 'ConfigurationOfContinousIntegration';
	load.
	
(Smalltalk at: #ConfigurationOfContinousIntegration) perform: #loadDefault.

tracker := GoogleIssueTracker pharo.
tracker authenticate: 'pharo.ulysse@gmail.com' with: 'AydsInJis'.


"===================================="
issue := tracker issue: #{issueNumber}.
issue loadAndTest.

Smalltalk snapshot: false andQuit: true.

IDENTIFIER
}
puts "Open the image and check the issue number #{issueNumber}"
`"#{vmPath}" "#{destination}/Monkey#{issueNumber}.image" "#{destination}/issueLoading.st"`

puts "Remove the folder #{destination}"
`rm -R "#{destination}"`
`date`