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
        @options.verbose      = false
        @options.quiet        = false
    end

    def run
        # Specify options
        @opts = OptionParser.new do |opts|
            opts.program_name = 'todo'
            opts.version = '0.1'
            opts.banner = 'todo [options] comment'

            opts.on("--list", "List all the pending TODOs") do |v|
                self.list_todos
                exit
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

            opts.on_tail('--hack', "Edit the programs source") { self.hack }
        end
        
        if ARGV.empty?
            puts @opts
            exit
        end

        @opts.parse!(@arguments)
        self.create_todo
    end
    
    protected
    def create_todo
      self.osascript { |stream|
            stream.puts "make new reminder with properties {name: \"#{ARGV.join(' ')}\"}" 
        }
    end

    def list_todos
        self.osascript { |stream| 
            stream.puts <<EOF
  set todoList to reminders whose completed is false
  set output to ""
  repeat with itemNum from 1 to (count of todoList)
      set output to output & (name of (item itemNum of todoList)) & return
  end repeat
  return output
EOF
        }
    end

    def osascript
        IO.popen('osascript', 'w') { |stream| 
            stream.puts 'tell app "Reminders"'
            yield stream
            stream.puts "end"
        }
    end


    def email
        return ENV['TODO_EMAIL'] if ENV['TODO_EMAIL']
        return ENV['EMAIL'] if ENV['EMAIL']
        @opts.abort 'Could not find $EMAIL ENV var'
    end


    def editor
        if ENV['EDITOR']
            return ENV['EDITOR']
        else
            return 'vim'
        end
    end

    def hack
        sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`.chomp
        exec(self.editor, sourceFile)
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

