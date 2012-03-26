#!/usr/bin/env ruby
# encoding: utf-8

def source()
    if ENV['H2_SOURCE']
        path = ENV['H2_SOURCE']
    else
        path = File.expand_path("~/.h2")
    end
    
    if not File.exist? path
        puts red("Could not find source file '#{path}'")
        exit 1
    end
    return path
end

def editor()
    if ENV['H2_EDITOR']
        return ENV['H2_EDITOR']
    elsif ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'vim'
    end
end

# ============================================================================
topics = {}
current_element = []

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

def check_action
    if $*[0] == "--edit"
        exec("#{editor()} #{source()}")
    elsif $*[0] == "--hack"
        sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`.chomp
        exec(editor(), sourceFile)
    end
end


def print_help
    puts <<EOF
h2 usage: h2 [command|searchstring]
    command: --edit 
             --hack 
    
Examples:   h2 bash
EOF
    exit 0
end

# ============================================================================

if __FILE__ == $0

    if $*.size == 1
        check_action()
    elsif $*.size == 0
        print_help()
    end
    
    File.readlines(source()).each { |line|
        if line =~/^\-\ (.*)/
            #opening a new topic
            current_element = []
            line = $1   # strip the leading "- "
            topics[line] = current_element 
        else
            #appending a new line to the current topic
            current_element.push line
        end
    }
    # find the matching groups -----------------------------------------------
    output = ''
    topics.each_pair { |k,v|
        matches = true
        $*.each {|search|
            if not k.downcase.match search.downcase and
               not v.join.downcase.match search.downcase
                 matches = false
                 break
            end
        }
        if matches
            # the header in green
            output += yellow(k.strip) + "\n"
            # strip the first indentation of each body line
            output += v.collect{|l| l.gsub(/^(\t|    )/, '')}.join.strip
            output += "\n\n"
        end
    }
    # colorize the matches ---------------------------------------------------
    output = output.split("\n")
    $*.each { |search|
        output.length.times { |i|
            # if its the green header line, add a green continue color
            if output[i].match('^\\033\[33m') or output[i][1]==91
                output[i].gsub!(search, "\033[32m" + '\0' + "\033[33m")
            else
                output[i].gsub!(search, "\033[32m" + '\0' + "\033[0m")
            end
        }
    }
    puts output.join("\n").strip
end 
