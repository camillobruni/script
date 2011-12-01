#!/usr/bin/env ruby
require 'fileutils'

def help
    $stderr.puts "usage #{$0} [pharo] [options] imageName"
    $stderr.puts ""
    $stderr.puts ""
    $stderr.puts "      --hack     edit the sources of this script"
    $stderr.puts "      -h/--help  show this help text"
end

if $*.size > 2 || $*.size == 0
    help
    exit 1
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

# ===========================================================================

version  = '1.4'
tmp      = `mktemp -d -t pharo`.chomp

if $*[0] == "pharo"
    subdir = $*[1]
    artifact = "Pharo-#{version}"
    imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/#{artifact}.zip"
	extraInstructions = ""
else
    subdir = $*[0]
    artifact = "Nautilus#{version}"
    imageUrl = "https://ci.lille.inria.fr/pharo/job/Nautilus/lastSuccessfulBuild/artifact/#{artifact}.zip"
	extraInstructions = "
SystemBrowser default: Nautilus.
package := RPackageOrganizer default packageNamed: 'Nautilus'. 
Nautilus groupsManager addADynamicGroupSilentlyNamed: 'Nautilus' block: [ package orderedClasses ].
"
end

destination = "#{Dir.pwd}/#{subdir}"
`mkdir #{subdir}`

# ===========================================================================

puts yellow("fetching the latest image")
puts "    #{imageUrl}"

`curl --progress-bar -o "#{artifact}.zip" "#{imageUrl}" &&  cp "#{artifact}.zip" "#{artifact}.bak.zip"  || cp "#{artifact}.bak.zip" "#{artifact}.zip"`

# ===========================================================================

#list = Dir["#{path}/#{artifact}*"]
#
#if list == []
#    id = nil
#else
#    lastName = list.last
#    id = lastName.split.last
#end
#
#if id == nil
#    arity = ""
#elsif id == artifact
#    arity = "\ 1"
#else
#    arity = "\ " + (id.to_i()+1).to_s
#end
#
#dir = artifact+arity
#destination = "#{path}/#{dir}"
#origin = "#{destination}/#{subdir}"
#
puts yellow("Unzipping image")

`unzip -x "#{artifact}.zip" -d "#{destination}"`
Dir::chdir(destination)


imagePath = `find . -name "*.image"`.chomp.split[0]
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
Author fullName: 'Camillo Bruni'.

Debugger alwaysOpenFullDebugger: true.

[ FreeTypeSystemSettings loadFt2Library: true ] onDNU: #loadFt2Library: do: [ :e| "ignore"].
FreeTypeFontProvider current updateFromSystem.

StandardFonts defaultFont: (LogicalFont familyName: 'Lucida Grande' pointSize: 10) forceNotBold.
GraphicFontSettings resetAllFontToDefault.

StandardFonts codeFont: (LogicalFont familyName: 'Consolas' pointSize: 10).

#{extraInstructions}

UITheme defaultSettings fastDragging: true. 

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}


# ===========================================================================

puts yellow("Setting up Image")
puts "    #{imagePath}"

`stackVM "#{imagePath}" "#{destination}/setup.st"`
`open #{imagePath}`
