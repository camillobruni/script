#!/usr/bin/env ruby
require 'fileutils'

def help
    $stderr.puts "    usage /.image pharo"
    $stderr.puts "              or"    
    $stderr.puts "    usage /.image nautilus"
    $stderr.puts "          hack     edit the sources of this script"
    $stderr.puts "          h/help  show this help text"
end

if $*.size > 1
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

if $*[0] == "help" || $*[0] == "h"
    help()
    exit 0
elsif $*[0] == "hack"
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
    exec("#{editor()} #{sourceFile}")
end




# ===========================================================================

version  = '1.4'
tmp      = `mktemp d t pharo`.chomp

if $*[0] == "pharo"
    imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo#{version}.zip"
    artifact = "Pharo#{version}"
    subdir = "Pharo#{version}"
    path = "/Users/benjamin/Images/Pharo 1.4"
elsif ($*[0] == "nautilus" or $*[0] == nil)
    artifact = "Nautilus#{version}"
    path = "/Users/benjamin/Images/Nautilus"
    subdir = artifact
    imageUrl = "https://ci.lille.inria.fr/pharo/job/Nautilus/lastSuccessfulBuild/artifact/#{artifact}.zip"
end

# ===========================================================================

puts "fetching the latest image"

`cd "#{path}" && wget nocheckcertificate "#{imageUrl}" outputdocument=artifact.zip`
list = Dir["#{path}/#{artifact}*"]

if list == []
    id = nil
else
    lastName = list.last
    id = lastName.split.last
end

if id == nil
    arity = ""
elsif id == artifact
    arity = "\ 1"
else
    arity = "\ " + (id.to_i()+1).to_s
end

dir = artifact+arity
destination = "#{path}/#{dir}"
origin = "#{destination}/#{subdir}"

`unzip x "#{path}"/artifact.zip d "#{path}/#{dir}"`

Dir.glob(File.join(origin, '*')).each do |file|
    FileUtils.mv file, File.join(destination, File.basename(file))
end

`rm R "#{origin}"`
`rm "#{path}"/artifact.zip`
`rm rf "#{tmp}"`

# ===========================================================================

File.open("#{destination}/setup.st", 'w') {|f| 
    f.puts <<IDENTIFIER

Author fullName: 'BenjaminVanRyseghem'.

"Debugger alwaysOpenFullDebugger: true."

FreeTypeSystemSettings loadFt2Library: true.
FreeTypeFontProvider current updateFromSystem.

((MCRepositoryGroup allInstances gather:#repositories) asSet detect: [:e| e description = 'http://www.squeaksource.com/Nautilus'] ifNone: [^ self]) user:'BVR'; password: 'Nemesis'.

StandardFonts defaultFont: (LogicalFont familyName: 'Lucida Grande' pointSize: 10) forceNotBold.
GraphicFontSettings resetAllFontToDefault.

StandardFonts codeFont: (LogicalFont familyName: 'Consolas' pointSize: 10).

"PolymorphSystemSettings desktopColor: Color gray."

"LogoImageMorph default: nil.
World backgroundMorph: nil.
World restoreDisplay."

UITheme defaultSettings fastDragging: true. 

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}

`pharo headless "#{destination}/#{subdir}.image" "#{destination}/setup.st"`
`rm "#{destination}/setup.st"`
`open "#{destination}/#{subdir}.image" &`