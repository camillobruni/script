#!/usr/bin/env ruby
require 'fileutils'

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

def help(msg=nil, exitStatus=0)
    if msg
        $stderr.puts red(msg)
        $stderr.puts ""
    end
    $stderr.puts "USAGE: #{$0} [1.4 2.0] [options] IMAGE_NAME"
    $stderr.puts ""
    $stderr.puts "     Creates a new image at `$IMAGE_NAME/$IMAGE_NAME.image` and installs a"
    $stderr.puts "     symlink $IMAGE_NAME/package-cache -> ./package-cache"
    $stderr.puts ""
    $stderr.puts "     If the `pharo` argument is passed along take a standard Pharo Image"
    $stderr.puts "     otherwise take a fresh Nautilus image."
    $stderr.puts ""
    $stderr.puts "      --hack     edit the sources of this script"
    $stderr.puts "      -h/--help  show this help text"

    exit exitStatus
end


def editor()
    if ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'vim'
    end
end

# ===========================================================================

if $*[0] == "--help" || $*[0] == "-h"
    help()
elsif $*[0] == "--hack"
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
    exec("#{editor()} #{sourceFile}")
elsif $*[0][0] == '-' || $*.size > 2 || $*.size == 0
    help("invalid arguments \"#{$*.join}\"", 1)
end

# ===========================================================================

version           = ''
extraInstructions = ""

if $*[0] == "1.4"
    subdir   = $*[1]
    version  = '1.4'
    artifact = "Pharo-#{version}"
    imageUrl = 'http://pharo.gforge.inria.fr/ci/image/14/latest.zip'
else
    version  = 'latest'
    subdir  = $*[0]
    artifact = "Pharo-#{version}"
    imageUrl = 'http://pharo.gforge.inria.fr/ci/image/20/latest.zip'
end

puts yellow("Building #{version} image")
# ===========================================================================

destination = "#{Dir.pwd}/#{subdir}"

if File.exists? destination
    puts red("Image has been created before:")
    puts destination
    while true
        print 'exit[E], reuse[r] or delete[d] files: '
        result = $stdin.gets.downcase.chomp
        break if ['e', 'r', 'd'].include? result
        break if result.empty?
    end

    case result
    when 'r'
        
    when 'd'    
        `rm -rf #{destination}`
    else
        exit 0
    end
end

tmp      = `mktemp -d -t pharo`.chomp
`mkdir #{destination}`
`cd #{destination} && ln -s ../package-cache ./`if File.exists? 'package-cache'

# ===========================================================================

puts yellow("Fetching the latest image")
puts imageUrl

`curl --progress-bar --retry 1 --retry-delay 1 --insecure --connect-timeout 3 --retry-max-time 4 -o "#{artifact}.zip" "#{imageUrl}" || cp "#{artifact}.bak.zip" "#{artifact}.zip"`

# ===========================================================================

puts yellow("Unzipping image")
`unzip -x "#{artifact}.zip" -d "#{destination}" > /dev/null 2>&1`

Dir::chdir(destination)
imagePath = `find . -name "*.image"`.chomp.split[0]

# consider using the backed-up zip if the image file can't be found
if imagePath.nil? or not File.exist? imagePath
    #Code duplication? nooooo, where?
    Dir::chdir('..')
    puts red("Could not properly download image files restoring local backup")
    `cp "#{artifact}.bak.zip" "#{artifact}.zip"`
    puts yellow("Unzipping image")
    `unzip -x "#{artifact}.zip" -d "#{destination}"`
    Dir::chdir(destination)
    imagePath = `find . -name "*.image"`.chomp.split[0]
end

# create a backup
`cp "../#{artifact}.zip" "../#{artifact}.bak.zip"`

imagePath = imagePath.chomp(File.extname(imagePath))
FileUtils.move(imagePath+'.image', "#{subdir}.image")
FileUtils.move(imagePath+'.changes', "#{subdir}.changes")

if File.exists? File.dirname(imagePath)+"/PharoV10.sources"
    FileUtils.move(File.dirname(imagePath)+"/PharoV10.sources", "PharoV10.sources")
end

imagePath = "#{Dir.pwd}/#{subdir}.image"
`rm -R "#{artifact}"`

# ===========================================================================

File.open("#{destination}/setup.st", 'w') {|f| 
    f.puts <<IDENTIFIER
| color red green yellow white |
"============================================================================="
"some helper blocks for error printing"
color := [:colorCode :text|
    FileStream stderr 
        "set the color"
        nextPut: Character escape; nextPut: $[; print: colorCode; nextPut: $m;
        nextPutAll: text; crlf;
        "reset the color"
        nextPut: Character escape; nextPutAll: '[0m'.
].

red    := [:text| color value: 31 value: text ].
green  := [:text| color value: 32 value: text ].
yellow := [:text| color value: 33 value: text ].
white  := [:text| FileStream stderr nextPutAll: text; crlf ].
"============================================================================="

Author fullName: 'Camillo Bruni'.
World submorphs do: [:each | each delete ].

"============================================================================="

yellow value: 'Updating image'.

UpdateStreamer new 
    beSilent; 
    elementaryReadServerUpdates.

"============================================================================="

yellow value: 'Loading custom preferences'.

Debugger alwaysOpenFullDebugger: true.

white value: '- enabling TrueType fonts'.
FreeTypeSystemSettings loadFt2Library: true.
FreeTypeFontProvider current updateFromSystem.

white value: '- set default fonts'.
StandardFonts defaultFont: (LogicalFont familyName: 'Lucida Grande' pointSize: 10) forceNotBold.
GraphicFontSettings resetAllFontToDefault.
StandardFonts codeFont: (LogicalFont familyName: 'Consolas' pointSize: 10).

white value: '- preparing tools'.
PolymorphSystemSettings 
	desktopColor: Color gray;
	showDesktopLogo: false.

"UITheme currentSettings fastDragging: true."

TextEditorDialogWindow autoAccept: true.

"============================================================================="

(Workspace new contents: '';
    openLabel: '')
	width: 1200; height: 230;
	setToAdhereToEdge: #bottomLeft;
	makeUnclosable.

MCWorkingCopyBrowser new show window
	width: 700; height: 230;
	setToAdhereToEdge: #topLeft;
	makeUnclosable.
    
"============================================================================="

#{extraInstructions}

"============================================================================="

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}


# ===========================================================================

puts yellow("Setting up Image")
puts imagePath

`cogVM "#{imagePath}" "#{destination}/setup.st"`
`open #{imagePath}`
