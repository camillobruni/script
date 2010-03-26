#!/usr/bin/env ruby 

# == Synopsis 
#   This is a sample description of the application.
#   Blah blah blah.
#
# == Examples
#   This command does blah blah blah.
#     ruby_cl_skeleton foo.txt
#
#   Other examples:
#     ruby_cl_skeleton -q bar.doc
#     ruby_cl_skeleton --verbose foo.html
#
# == Usage 
#   ruby_cl_skeleton [options] source_file
#
#   For help use: ruby_cl_skeleton -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#   TODO - add additional options
#
# == Author
#   YourName
#
# == Copyright
#   Copyright (c) 2007 YourName. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php
#   Original template from http://blog.infinitered.com/entries/show/5


# TODO - replace all ruby_cl_skeleton with your app name
# TODO - replace all YourName with your actual name
# TODO - update Synopsis, Examples, etc
# TODO - change license if necessary



require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'logger'  


class App
    VERSION = '0.0.1'
    
    attr_reader :options

    def initialize(arguments, stdin)
        @arguments = arguments
        @stdin     = stdin
        
        # Set defaults
        @options = OpenStruct.new
        @options.verbose = false
        @options.quiet   = false
        # TODO - add additional defaults
    end

    # Parse options, check arguments, then process the command
    def run
        if parsed_options? && arguments_valid? 
            puts "Start at #{DateTime.now}\n\n" if @options.verbose
      
            self.output_options if @options.verbose # [Optional]
            
            self.process_arguments            
            self.process_command
      
            puts "\nFinished at #{DateTime.now}" if @options.verbose
        else
            self.output_usage
        end
    end
    
    def hack
        exec("sudo vim #{__FILE__}")
    end

    protected
        def parsed_options?
            # Specify options
            opts = OptionParser.new 
            opts.on('-v', '--version') { self.output_version ; exit 0 }
            opts.on('-h', '--help')    { self.output_help }
            opts.on('-V', '--verbose') { @options.verbose = true }
            opts.on('-q', '--quiet')   { @options.quiet = true }
            opts.on('--hack') { self.hack }
            # TODO - add additional options
                  
            opts.parse!(@arguments) rescue return false
            
            self.process_options
            true      
        end
        
        # Performs post-parse processing on options
        def process_options
            @options.verbose = false if @options.quiet
        end
    
        def output_options
            puts "Options:\n" 
            @options.marshal_dump.each do |name, val|        
                puts "  #{name} = #{val}"
            end
        end

        # True if required arguments were provided
        def arguments_valid?
            # TODO - implement your real logic here
            true if @arguments.length == 1 
        end
    
        # Setup the arguments
        def process_arguments
            # TODO - place in local vars, etc
        end
        
        def output_help
            self.output_version
            RDoc::usage() #exits app
        end
        
        def output_usage
            RDoc::usage('usage') # gets usage from comments above
        end
        
        def output_version
            puts "#{File.basename(__FILE__)} version #{VERSION}"
        end
        
        def process_command
            # TODO - do whatever this app does
          
            #process_standard_input # [Optional]
        end

        def process_standard_input
            input = @stdin.read      
            # TODO - process input
          
            # [Optional]
            # @stdin.each do |line| 
            #  # TODO - process each line
            #end
        end
end


# TODO - Add your Modules, Classes, etc

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

