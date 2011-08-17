#!/usr/bin/env ruby

if $*.size != 1
    $stderr << "    usage /.image projectName"
    exit 1
end

# ===========================================================================

name     = $*[0]
version  = '1.4'
imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/Pharo-#{version}.zip"

# ===========================================================================

`mkdir #{name} &> /dev/null`
if not $?.success? 
    $stderr.puts "    project #{name} exists already"
    exit 1
end

# ===========================================================================

puts "fetching the latest image"

`wget #{imageUrl} --output-document=pharo.zip`


`unzip pharo.zip`
`mv Pharo-#{version}/* foo/`
`rm -rf Pharo-#{version}/`

# ===========================================================================

`mv #{name}/Pharo-#{version}.image #{name}/#{name}.image`
`mv #{name}/Pharo-#{version}.changes #{name}/#{name}.changes`

# ===========================================================================

File.open("#{name}/setup.st", 'w') {|f| 
    f.puts <<IDENTIFIER

Author fullName: 'CamilloBruni'.

Debugger alwaysOpenFullDebugger: true.

FreeTypeFontProvider current updateFromSystem.

StandardFonts defaultFont: (LogicalFont familyName: 'Lucida Grande' pointSize: 10) forceNotBold.
GraphicFontSettings resetAllFontToDefault.

StandardFonts codeFont: (LogicalFont familyName: 'Consolas' pointSize: 10).

Smalltalk snapshot: true andQuit: true.

PolymorphSystemSettings desktopColor: Color gray.

LogoImageMorph default: nil.
World backgroundMorph: nil.
World restoreDisplay.

UITheme defaultSettings fastDragging: true. 

IDENTIFIER
}

`pharo $PWD/#{name}/#{name}.image $PWD/#{name}/setup.st`
