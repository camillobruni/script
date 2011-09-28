#!/usr/bin/env ruby

require 'fileutils'
require 'timeout'

# ============================================================================

def help
    $stderr.puts "    usage /.image issueNumber"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"
end

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

if $*.size != 1
    help
    exit 1
end


def guard()
    exit $?.to_i if !$?.success?
end

# ===========================================================================

issueNumber = $*[0]
version  = '1.4'
tmp      = `mktemp -d -t pharo`.chomp

imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"
artifact = "Pharo#{version}"
name = "Pharo-#{version}"
destination = "Monkey#{issueNumber}"

# ============================================================================


puts "fetching the latest image"
`wget --tries=1 --timeout=3 --no-check-certificate "#{imageUrl}" --output-document="artifact#{issueNumber}.zip" \
    && cp "artifact#{issueNumber}.zip" "/backup.zip"  \
    || cp "backup.zip" "artifact#{issueNumber}.zip"`
guard()

puts "Unzipping the archive"
`unzip -x "artifact#{issueNumber}.zip" -d "#{destination}"`
Dir::chdir(destination)
guard()

imagePath = `find . -name "*.image"`.chomp
imagePath = imagePath.chomp(File.extname(imagePath))
FileUtils.move(imagePath+'.image', "Monkey#{issueNumber}.image")
FileUtils.move(imagePath+'.changes', "Monkey#{issueNumber}.changes")

if File.exists? File.dirname(imagePath)+"/PharoV10.sources"
    FileUtils.move(File.dirname(imagePath)+"/PharoV10.sources", "PharoV10.sources")
end

puts "Cleanup"
`rm "../artifact#{issueNumber}.zip" && rm -rf "#{tmp}"`
guard()

# ===========================================================================

exit 1 if !system("ping -c 1 ss3.gemstone.com")

File.open("issueLoading.st", 'w') {|f| 
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

"===================================="
tracker := GoogleIssueTracker pharo.
tracker authenticate: 'pharo.ulysse@gmail.com' with: 'AydsInJis'.

"===================================="
issue := tracker issue: #{issueNumber}.
Smalltalk at: 'MonkeyIssue' put: issue.
Smalltalk snapshot: true andQuit: false.
"===================================="

issue loadAndTest.

"===================================="
Smalltalk snapshot: false andQuit: true.

IDENTIFIER
}

pid = 0
begin
    #kill the build process after 15 minutes
    puts "Open the image and check the issue number #{issueNumber}"
    timeout(15 * 60) {
        pid = Process.spawn("pharo '#{Dir.pwd}/Monkey#{issueNumber}.image' '#{Dir.pwd}/issueLoading.st'")
        puts pid
        Process.wait
    }
rescue Timeout::Error    
    puts pid
    Process.kill('KILL', pid)
    Process.kill('KILL', pid+1) #this is pure guess...
    puts "Loading #{issueNumber} took longer than 15mins"
    File.open("issueLoading.st", 'w') {|f| 
        f.puts <<IDENTIFIER
            (Smalltalk at: 'MonkeyIssue') 
                reviewNeeded: 'Timeout occured while loading and testing the code'.
            Smalltalk snapshot: false andQuit: true.
IDENTIFIER
    }
    `pharo "#{Dir.pwd}/Monkey#{issueNumber}.image" "#{Dir.pwd}/issueLoading.st"`
end


puts "Remove the folder #{destination}"
`rm -R "#{destination}"`
