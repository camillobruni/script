#!/usr/bin/env ruby

def help
    $stderr.puts "    usage /.image projectName"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"
    $stderr.puts "          -c/--core  use the core image instead of the nautilus image"
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

# ===========================================================================

version  = '1.4'

if $*[0] == '--core' || $*[0] == '-c'
    $*.shift
    artifact = "Pharo-1.4"
    imageUrl = "https://ci.lille.inria.fr/pharo/view/Pharo%20#{version}/job/Pharo%20#{version}/lastSuccessfulBuild/artifact/#{artifact}.zip"
else
    artifact = "Nautilus1.4"
    imageUrl = "https://ci.lille.inria.fr/pharo/job/Nautilus/lastSuccessfulBuild/artifact/#{artifact}.zip"
end
name     = $*[0].gsub(" ", "_")
tmp      = `mktemp -d -t pharoXXXXX`.chomp

# ===========================================================================

puts "Creating the project dir"
`mkdir "#{name}" &> /dev/null`
if not $?.success? 
    $stderr.puts "    project '#{name}' already exists"
    exit 1
end

# ===========================================================================

puts "fetching the latest image"

`wget --no-check-certificate #{imageUrl} --output-document=#{tmp}/artifact.zip`

puts "Unzipping the downloaded files"
`unzip #{tmp}/artifact.zip -d #{tmp}`
`mv #{tmp}/#{artifact}/* "#{name}/"`
`rm -rf #{tmp}`

# ===========================================================================
puts "Copy over the files"
`mv "#{name}/#{artifact}.image" "#{name}/#{name}.image"`
`mv "#{name}/#{artifact}.changes" "#{name}/#{name}.changes"`
`ln -s "#{Dir.pwd}/package-cache" "#{name}/package-cache"` if File.exists? 'package-cache'

# ===========================================================================

puts "Creating setup files"
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

"open up a default workspace"
ws := Workspace new.
(ws openLabel: '1st Workspace') 
    makeUnclosable;
    extent: 500@300;
    setToAdhereToEdge: #bottomLeft.

"open up default mc working copy browser"
MCWorkingCopyBrowser new window
    makeUnclosable;
    openInWorldExtent: 700@300;
    setToAdhereToEdge: #topLeft.

Smalltalk snapshot: true andQuit: true.

IDENTIFIER
}

puts "Install the setup"
`stackVM "#{Dir.pwd}/#{name}/#{name}.image" "#{Dir.pwd}/#{name}/setup.st"`

puts "Open the image"
`open "#{Dir.pwd}/#{name}/#{name}.image"`
