#!/usr/bin/env ruby

require 'fileutils'
require 'timeout'

# ===========================================================================
updateImage = true
issueNumber = $*[0]
version  = '1.4'
tmp      = `mktemp -d -t pharoXXXXX`.chomp

imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"
artifact = "Pharo#{version}"
name = "Pharo-#{version}"
destination = "Monkey#{issueNumber}"

# ============================================================================

def help
    $stderr.puts "    usage /.image issueNumber"
    $stderr.puts ""
    $stderr.puts "    loads and tests an issue from the google issue tracker at http://code.google.com/p/pharo/issues/list"
    $stderr.puts "    this script will update the issue status and adds comments if the errors occur during loading"
    $stderr.puts ""
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
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`.chomp
    exec(editor(), sourceFile)
end

if $*.size != 1
    help
    exit 1
end


def guard()
    exit $?.to_i if !$?.success?
end

# ============================================================================

def colorize(text, color_code)
  "\033#{color_code}#{text}\033[0m"
end

def red(text)
    colorize(text, "[31m")
end

def green(text)
    colorize(text, "[32m")
end

def yellow(text)
    colorize(text, "[33m")
end

# ============================================================================

if File.exists? destination
    puts red("Issue has been loaded before #{Dir.pwd}/#{destination}")
    while true
        print 'exit[e], reuse[r] or delete[D] files: '
        result = $stdin.gets.downcase.chomp
        break if ['e', 'r', 'd'].include? result
        break if result.empty?
    end

    case result
    when 'e'
        exit 0
    when 'r'    
        puts red('resuse not yet implemented')
        exit 1
    else
        `rm -rf #{destination}`
    end
end

# ============================================================================

if updateImage
    puts yellow("Fetching the latest image")
        `curl --progress-bar -o "artifact#{issueNumber}.zip" "#{imageUrl}" \
        && cp "artifact#{issueNumber}.zip" "backup.zip"  \
        || cp "backup.zip" "artifact#{issueNumber}.zip"`
else
    `cp "backup.zip" "artifact#{issueNumber}.zip"`
end
guard()


# ============================================================================

puts yellow("Unzipping the archive")
`unzip -x "artifact#{issueNumber}.zip" -d "#{destination}" && rm -rf "#{destination}/__MACOSX"`
Dir::chdir(destination)
guard()

imagePath = `find . -name "*.image"`.chomp
imagePath = imagePath.chomp(File.extname(imagePath))
FileUtils.move(imagePath+'.image', "Monkey#{issueNumber}.image")
FileUtils.move(imagePath+'.changes', "Monkey#{issueNumber}.changes")

if File.exists? File.dirname(imagePath)+"/PharoV10.sources"
    FileUtils.move(File.dirname(imagePath)+"/PharoV10.sources", "PharoV10.sources")
end

# ============================================================================
#
puts yellow("Cleaing up unzipped files")
`rm "../artifact#{issueNumber}.zip" && rm -rf "#{tmp}"`
guard()

# ===========================================================================

if !system("ping -c 1 ss3.gemstone.com > /dev/null")
    puts red('Could not find ss3.gemstone.com')
    exit 1
end

# ===========================================================================
File.open("issueLoading.st", 'w') {|f| 
f.puts <<IDENTIFIER
| tracker issue |

World submorphs do: [:each | each delete ].

Smalltalk garbageCollect.
Smalltalk garbageCollect.
Smalltalk garbageCollect.

Author fullName: 'MonkeyGalactikalIntegrator'.

"===================================="
UpdateStreamer new 
    beSilent; 
    elementaryReadServerUpdates.

"===================================="
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
"===================================="

issue loadAndTest.

"===================================="
Smalltalk snapshot: false andQuit: true.

IDENTIFIER
}

pid = 0
begin
    #kill the build process after 1 hour
    puts yellow("Opening the image for issue ##{issueNumber}")
    puts "    http://code.google.com/p/pharo/issues/detail?id=#{issueNumber}"
    timeout(60 * 60) {
        pid = Process.spawn("stackVM '#{Dir.pwd}/Monkey#{issueNumber}.image' '#{Dir.pwd}/issueLoading.st'")
        Process.wait
    }
rescue Timeout::Error    
    Process.kill('KILL', pid)
    Process.kill('KILL', pid+1) #this is pure guess...
    puts red("Loading #{issueNumber} took longer than 15mins")
    File.open("issueLoading.st", 'w') {|f| 
        f.puts <<IDENTIFIER
"===================================="
tracker := GoogleIssueTracker pharo.
tracker authenticate: 'pharo.ulysse@gmail.com' with: 'AydsInJis'.
"===================================="

issue := tracker issue: #{issueNumber}.
issue reviewNeeded: 'Timeout occured while loading and testing the code'.
Smalltalk snapshot: false andQuit: true.
IDENTIFIER
    }
    `stackVM "#{Dir.pwd}/Monkey#{issueNumber}.image" "#{Dir.pwd}/issueLoading.st"`
end


# ===========================================================================

while true
    print "Remove the folder #{Dir.pwd} [yN]?"
    result = $stdin.gets.downcase.chomp
    break if ['y', 'N',].include? result
    break if result.empty?
end

case result
when 'y'
    `rm -R "#{Dir.pwd}"`
else
    `open #{Dir.pwd}`
end

puts `date`
`open "http://code.google.com/p/pharo/issues/detail?id=#{issueNumber}"`
