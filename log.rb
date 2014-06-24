#!/usr/bin/env ruby

require 'date'


# ============================================================================
def get_file(date)
    date.strftime("%Y-%m-%d-%a") + ".txt"
end


def create_log
    file = get_file(DateTime.now)
    
    puts file
    
    return file if File.exists? file
    
    File.open(file, 'w') {|f| 
        f.write <<-HEREDOC
#{DateTime.now.to_s}
Planned
=======

Achieved
========
            HEREDOC
    }
    `git add #{file}`
    `git commit -a -m 'new log file'`
    return file
end


def ensure_log()
    file = get_file(DateTime.now)
    return file if File.exist? file
    return create_log()
end

def new_log
    file = create_log()
    exec("#{editor()}  #{file}")
end

def open_log()
    exec("less #{get_file(DateTime.now)}")
end

def add_log_entry(text)
    file = ensure_log()
    File.open(file, 'a+') do |file|
        file.print '- ['
        file.print Time.new.strftime('%H:%M:%S').to_s
        file.print '] '
        file.puts text
    end
end

# ============================================================================

def run_action
    action = $*[0]
    if action == "--help" || action == "-h"
        print_help()
    elsif action == "--hack"
        edit_source()
    elsif ["--last", "-l", "last", "l"].include? action
        show_last()
    elsif action == 'add'
        add_log_entry($*[1..-1].join(' '))
    elsif action =~ /^l([0-9]+)/
        show_last($1)
    elsif action =~ /^\-([0-9]+)/
        show_offset($1)
    elsif ["all", "--all"].include? action
        show_all()
    elsif action == 'summary'
        ARGV.push '' if ARGV.size == 1 
        show_summary(ARGV.last)
    else
       puts "invalid arguments given: #{$*.join(', ')}"
       exit 1
    end
end

# ============================================================================
def edit_source
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
    exec("#{editor()} #{sourceFile}")
end


def editor
    if ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'vim'
    end
end


def print_help
    puts <<EOF
log usage: log [command|offset]
    command: --help/-h
             --hack 
    
Examples:
    log                    # opens the log file for the current day
    log -2                 # opens the log from two days ago
    log l2                 # opens the second log in the past
    log summary [WEEKNUM]  
    log add contents       # adds the given text to the current log file
EOF
    exit 0
end


def show_last(offset=0)
    offset = offset.to_i.abs
    files = Dir["*.txt"].sort.reverse
    exec("#{editor()} #{files[offset]}")
end


def show_offset(offset)
    offset = offset.to_i.abs
    exec("#{editor()} #{get_file(DateTime.now.new_offset(-offset))}")
end


def show_all
    files = Dir["*.txt"].sort.reverse
    exec("cat #{files.join ' '} | less")
end


def show_summary(week=nil)
  if week.nil? || week.empty?
      # use the last week      
      week = Date.today.strftime("%V").to_i - 1
  else 
      week = week.to_i
  end
  week_start_date = Date.commercial(Date.today.year, week)
  puts "SUMMARY FOR WEEK #{week} STARTING AT #{week_start_date}"
  (0..6).each { |day|
      date = week_start_date + day
      puts date.strftime(" %A ").center(80, "-")
      file = get_file(date)
      if File.exists? file
          #File.open(file).each.drop(3).each { |line|
          File.open(file).each { |line|
              puts line
          }
          puts ""
      end
  }
end

# ============================================================================

def run
  if $*.empty?
      return new_log()
  elsif $*.size >= 1
      return run_action()
  end
end
# ============================================================================

def dir
    begin
        return File.readlink $0
    rescue
        return $0
    end
end

if __FILE__ == $0
    DIR = Dir.chdir File.dirname dir
    run()
end
