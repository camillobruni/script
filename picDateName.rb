#!/usr/bin/env ruby 

# == Author
#   Camillo Bruni
#
# == Copyright
#   Copyright (c) Camillo Bruni 2011. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php
#   Original template from http://blog.infinitered.com/entries/show/5


require 'optparse' 
require 'ostruct'
require 'logger'  
require 'find'
require 'colorize'
require 'date'

class App
    VERSION = '0.1.0'
    
    attr_reader :options

    def initialize(arguments, stdin)
        @arguments = arguments
        @stdin     = stdin
        
        # Set defaults
        @verbose            = false
        @quiet              = false
        @dry_run            = false
        @recursive          = false
        @skip_unknown_files = false
    end

    # ========================================================================
    
    def run()
        begin
            self.parse
            self.rename_files(@arguments)
        rescue SystemExit
            return
        rescue Exception => error
            puts error.to_s.red
            puts ""
            if @debug
                puts error.backtrace
                puts
            end
            puts @options
            exit 1
        end
    end
    
    def parse()
        # Specify options
        @options = OptionParser.new do |opts|
            opts.program_name = 'picDateName'
            opts.version = VERSION
            opts.banner = <<COMMENT
Prefix image files with their creation date

Usage: picDateName [--dry|--recursive] FILE...
COMMENT
            opts.separator ""
            opts.separator "Specific options:"
            
            opts.on("--debug", "Print debugging information") do
                @debug = true
            end

            opts.on("--dry", "Dry run showing the changes") do
                @dry_run = true
            end
            
            opts.on("--skip", "Skip unknown file types") do
                @skip_unknown_files = true
            end
            
            opts.on("-R", "--recursive", "Rename image files recursively") do
                @recursive = true
            end

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
                  
        end
        @options.parse!(@arguments)
        if @arguments.empty?
            raise "No picture files provided"
        end
    end

     
    # ========================================================================
    
    def recursive?
        @recursive
    end

    def dry_run?
        @dry_run
    end

    def skip_unknown_files?
        @skip_unknown_files
    end

    # ========================================================================
    protected
    def rename_files(files)
        files = self.collect_pictures(files)
        self.basic_rename_files(files)
    end

    
    def collect_pictures(files)
        if self.recursive?
            return self.collect_pictures_recursive(files)
        end
        # find all files
        return files if files.all?{|path| FileTest.file? path}
        folders = files.select{|path| FileTest.directory? path} 
        raise "Folders detected, use --recursive: #{folders}"
    end

    def collect_pictures_recursive(files)
        pictures = []
        files.each{ |file|
            Find.find(file) do |path|
                if File.basename(path).start_with?(".")
                    # Don't look any further into this directory
                    Find.prune       
                else
                    pictures << path if FileTest.file?(path)
                    next
                end                
            end
        }
        pictures
    end

    def basic_rename_files(files)
        files.each { |file| self.basic_rename_file(file) }
    end

    def basic_rename_file(file)
        date = self.extract_picture_date(file)
        return if date.nil?
        
        custom_filename = self.extract_custom_filename(file)
        filename = "#{date}#{custom_filename}#{File.extname(file)}"
        new_file = File.join(File.dirname(file), filename) 
        
        destination_exists = File.exists?(new_file) && File.basename(file) != filename            

        if self.dry_run?
            puts "#{file} => #{filename}"
            puts "    Destination file exists #{new_file}".red if destination_exists
        else
            if destination_exists
                raise "Destination file exists #{new_file} for #{File.basename(file)}" 
            end
            File.rename(file, new_file)
        end
    end

    def extract_picture_date(file)
        date = `exiftool -S -dateFormat "%Y-%m-%dT%H:%M:%S" -CreateDate "#{file}"`.chomp
        if date.empty?
            message = "Unsupported picture file detected: #{file}"
            raise message unless self.skip_unknown_files?
            
            @options.warn(message)
            return nil
        end
        date = date.split(': ')[1]
        date = DateTime.parse(date)
        date.strftime("%Y-%m-%d_%H%M%S")
    end
    
    def extract_custom_filename(file)
        basename = File.basename(file, ".*")
        parts = basename.split(' ', 2)
        # return only the second part if the first part corresponds to an
        # autogenerated file (typically IMG_12345 or DSC_1234)
        return " #{parts[1]}".rstrip if parts[0] =~ /_?[A-Z]+_[0-9]+/
        return " #{parts[1]}".rstrip if parts[0] =~ /[0-9_\-.]+/
        return " #{parts.join(' ')}".rstrip
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
    app = App.new(ARGV, STDIN)
    app.run
end


