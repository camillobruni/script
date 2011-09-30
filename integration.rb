#!/usr/bin/env ruby
require 'fileutils'

def help
    $stderr.puts "    usage /.image issueNumber"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"
end


path = "/Users/benjamin/Images/Integration"

# ===========================================================================

version  = '1.4'
tmp      = `mktemp -d -t pharo`.chomp

imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"
artifact = "Pharo#{version}"
name = "Pharo-#{version}"
destination = "#{path}/PendingIntegration"
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


if (File.exists? "#{path}/artifact.zip")
	puts "Integration already in progress, please wait"
	exit 1
end

`cd "#{path}" && wget --tries=2 --timeout=3 --no-check-certificate "#{imageUrl}" --output-document="artifact.zip"
puts "Unzipping the archive"
`unzip -x "#{path}/artifact.zip" -d "#{destination}"`
`cd "#{destination}" && mv "#{name}/#{name}.image" "PendingIntegration.image" ; mv "#{name}/#{name}.changes" "PendingIntegration.changes" ; mv "#{name}/PharoV10.sources" PharoV10.sources`

puts "Cleanup"
`rm -rf "#{tmp}"`

# ===========================================================================


File.open("#{destination}/integration.st", 'w') {|f| 
    f.puts <<IDENTIFIER

| tracker |

World submorphs do: [:each | each delete ].

Smalltalk garbageCollect.
Smalltalk garbageCollect.
Smalltalk garbageCollect.

Author fullName: 'Integrator'.

Gofer new
	url: 'http://ss3.gemstone.com/ss/ci';
	package: 'ConfigurationOfContinousIntegration';
	load.
	
(Smalltalk at: #ConfigurationOfContinousIntegration) perform: #loadDefault.

tracker := GoogleIssueTracker pharo.
tracker authenticate: 'pharo.ulysse@gmail.com' with: 'AydsInJis'.


"===================================="

IntegrationManager integrate: {#{$*.join('. ')}}.

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}
puts "Retrieving file"
`sh getUpdateFiles`

puts "Open the image and start a new integration"
`"#{vmPath}" "#{destination}/PendingIntegration.image" "#{destination}/integration.st"`

puts "Push the updates.list"
`upFiles "#{destination}/updates.list"`

puts "Remove the folder #{destination}"
`rm -R "#{destination}"`
`rm "#{path}/artifact.zip"`