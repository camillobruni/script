#!/usr/bin/env ruby 


# == Author
#   Camillo Bruni
#
# == Copyright
#   Copyright (c) Camillo Bruni 2011. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php



require 'optparse' 
require 'ostruct'
require 'logger'  
require 'colorize'


class App
    VERSION = '0.0.1'
    
    attr_reader :options

    def initialize(arguments, stdin)
        @arguments = arguments
        @stdin     = stdin
        @use_tags  = false
        @dry_run   = false
        @list_existing = false
        
        # Set defaults
        @options = OpenStruct.new
        @options.verbose = false
        @options.quiet   = false
    end

    def run
        # Specify options
        opts = OptionParser.new do |opts|
            opts.program_name = 'picasa2DesktopPictures'
            opts.version = VERSION
            opts.banner = 'picasa2DesktopPictures [-h|--dry-run|--use-tags|--list-existing]'
            
            opts.separator ""
            opts.separator "Specific options:"
            
            #ADD CUSTOM OPTIONS HERE

            opts.separator ""
            opts.separator "Common options:"

            opts.on_tail("-h", "--help", "Show this message") do
                puts opts
                exit
            end

            opts.on_tail("--version", "Show version") do
                puts opts.version
                exit
            end

            opts.on_tail('--hack', "Edit the programs source") do
                self.hack
            end
            
            opts.on("--list-existing", "List existing files during dry-run") do
                @list_existing = true
            end

            opts.on("--dry", "Dry run showing the changes only") do
                @dry_run = true
            end

            opts.on("--use-tags", "Use the 'desktop' tag to indentify pictures") do
                @use_tags = true
            end
        end

        opts.parse!(@arguments)
        self.process_command
    end
     
    # ========================================================================
    
    def dry_run?
        @dry_run
    end
    
    def use_tags?
      return @use_tags
    end
    
    def destination
      return ENV['HOME']+'/Library/Desktop Pictures/'
    end
     
    # ========================================================================
    
    protected
    def process_command
      for image_file in self.image_list()
        self.link_image_file(image_file)
      end
    end
    
    def image_list()
      return self.image_list_by_tags() if self.use_tags?
      return self.image_list_starred()
    end
    
    def image_list_starred()
      images = []
      picasa_file = ENV['HOME']+'/Library/Application Support/Google/Picasa3/db3/starlist.txt'
      return File.read(picasa_file).split("\n")
    end
    
    def image_list_by_tags()
      tags = ['desktop']
      return `mdfind -interpret -onlyin #{ENV['HOME']}/Pictures kind:image #{tags.join(' ')}`.split("\n")
    end
    
    def link_image_file(file)
      if self.dry_run?
        return self.link_dry_run(file)
      end
      return if self.destination_exists?(file)
      File.symlink(file, self.destination + '/' + File.basename(file))
    end
    
    def link_dry_run(file)
      if self.destination_exists?(file)
        puts '~ '+File.basename(file).yellow if @list_existing
        return
      end
      puts '+ '+file.green
    end

    def destination_exists?(file)
      return File.exists?(self.destination + File.basename(file))
    end
    
    # ========================================================================
    def editor()
        if ENV['EDITOR']
            return ENV['EDITOR']
        else
            return 'vim'
        end
    end

    def hack
        sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`.chomp
        exec(self.editor(), sourceFile)
    end
end


# ============================================================================

if __FILE__ == $0
    # preamble to change to the current scripts dir
    def dir
        begin 
            return File.readlink $0
        rescue
            return $0
        end
    end
    DIR = Dir.chdir File.dirname dir
    
    # Create and run the application
    app = App.new(ARGV, STDIN)
    app.run
end


