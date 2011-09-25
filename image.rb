#!/usr/bin/env ruby

def help
    $stderr.puts "    usage /.image projectName"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"
end

if $*.size != 1
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

# ===========================================================================

name     = $*[0]
version  = '1.4'
imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"
artifact = "Nautilus1.4"
imageUrl = "https://ci.lille.inria.fr/pharo/job/Nautilus/lastSuccessfulBuild/artifact/#{artifact}.zip"
tmp      = `mktemp -d -t pharo`.chomp

# ===========================================================================


`mkdir #{name} &> /dev/null`
if not $?.success? 
    $stderr.puts "    project #{name} exists already"
    exit 1
end

# ===========================================================================

puts "fetching the latest image"

`wget #{imageUrl} --output-document=#{tmp}/artifact.zip`


`unzip #{tmp}/artifact.zip -d #{tmp}`
`mv #{tmp}/#{artifact}/* #{name}/`
`rm -rf #{tmp}`

# ===========================================================================

`mv #{name}/#{artifact}.image #{name}/#{name}.image`
`mv #{name}/#{artifact}.changes #{name}/#{name}.changes`

# ===========================================================================

File.open("#{name}/setup.st", 'w') {|f| 
    f.puts <<IDENTIFIER

Author fullName: 'CamilloBruni'.

Debugger alwaysOpenFullDebugger: true.

FreeTypeSystemSettings loadFt2Library: true.
FreeTypeFontProvider current updateFromSystem.

StandardFonts defaultFont: (LogicalFont familyName: 'Lucida Grande' pointSize: 10) forceNotBold.
GraphicFontSettings resetAllFontToDefault.

StandardFonts codeFont: (LogicalFont familyName: 'Consolas' pointSize: 10).

PolymorphSystemSettings desktopColor: Color gray.

LogoImageMorph default: nil.
World backgroundMorph: nil.
World restoreDisplay.

UITheme defaultSettings fastDragging: true. 

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}

`pharo $PWD/#{name}/#{name}.image $PWD/#{name}/setup.st`

`open $PWD/#{name}/#{name}.image &`
