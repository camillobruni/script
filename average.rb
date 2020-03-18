#!/usr/bin/env ruby
# encoding: utf-8

require 'optparse'
require 'tmpdir'
require 'ostruct'
require 'timeout'
require 'pty'
require 'open3'


module Enumerable
    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def geomean
      sum=0.0
      self.each {|v| sum += Math.log(v)}
      sum /= self.size
      Math.exp(sum)
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation
      return Math.sqrt(self.sample_variance)
    end
end

TICKS = " ▁▂▃▄▅▆▇█"

$results = []
def shut_down
    puts("=" * 79)
    if $results.empty?
        STDERR.puts("Empty results")
        exit
    end
    begin
        Dir::Tmpname.create('average_') { |path|
            path += '.txt'
            puts "Storing result to: " + path
            File.open(path, 'w') { |f|
                f.puts('# ' + ARGV.join(" "))
                f.puts($results)
            }
        }
    rescue
    end
    stdev = $results.standard_deviation
    mean = $results.mean
    roundTo =  if stdev == 0.0 then 1 else 10.0**Math::log10(stdev).ceil / 100.0 end
    # Figure out the first non-digit in the standard deviation
    meanRounded = (mean / roundTo).round * roundTo
    stdevRounded = (stdev / roundTo).round * roundTo
    minRounded = ($results.min / roundTo).round * roundTo
    maxRounded = ($results.max / roundTo).round * roundTo
    stdevPercentage = (100.0 * stdev / mean).round(2)
    puts("=" * 79)
    puts("command = #{ARGV.join(" ")}")
    puts("runs    = #{$results.size}")
    puts("avg     = #{$results.mean}")
    puts("geomean = #{$results.geomean}")
    puts("min     = #{minRounded}        max = #{maxRounded}")
    puts("result  = #{meanRounded} ± #{stdevRounded}(#{stdevPercentage}%)")
    puts("." * 80)
    printHistogram($results)
    puts("." * 80)
end

def printHistogram(list)
    min,max = list.minmax
    return if min == max

    map = -> (x) { x }
    unmap = map

    # use log scaling if min and max are very far apart:
    if max/min > 10
        map = ->(x) { Math.log10(x) }
        unmap = ->(x) { 10 ** x }
    end

    # find the constant factor for a logarithmic distribution of 71 buckets
    minMappedValue = map.call(min).floor()
    maxMappedValue = map.call(max).ceil()
    logStep = 70.0 / (maxMappedValue - minMappedValue)
    buckets = [0] * 71
    list.each{ |i|
        bucket =  ((map.call(i) - minMappedValue) * logStep).round()
        buckets[bucket] += 1
    }
    minCount,maxCount = buckets.minmax
    scale = (2*TICKS.size() - 1).to_f / (maxCount-minCount)
    buckets = buckets.map{|each| (each * scale).ceil() }
    # upper row:
    print(maxCount.to_s.rjust(4)+" ")
    buckets.each{ |value|
        print(TICKS[[0, value - TICKS.size()].max])
    }
    puts("")
    # lower row:
    print(minCount.to_s.rjust(4)+" ")
    buckets.each{ |value|
        print(TICKS[[TICKS.size()-1, value].min])
    }
    puts("")
    # bottom labels:
    str = "    "+unmap.call(minMappedValue).to_s
    middleStr = unmap.call((minMappedValue + maxMappedValue) / 2.0).to_s
    maxStr = unmap.call(maxMappedValue).to_s
    str += middleStr.center(80-str.size()-maxStr.size(), ' ')
    str += maxStr
    puts(str)
end


MATCHER = [
    # Try matching 4'793 ops/sec
    lambda { |result| result.match(/([0-9'\.]+) ops\/sec/m)[0].gsub("'","").to_f },
    # Try matching: 12.235ms
    lambda { |result| result.match(/(\d+(\.\d+)?)\s*ms/m)[0].to_f },
    # Try matching: 12.235
    lambda { |result| result.match(/\d+\.\d+/m)[0].to_f },
    # Last resort simple number matching
    lambda { |result| result.match(/\d+/m)[0].to_f }
]

def extractNumber(result)
    #  extract float
    MATCHER.each do |matcher|
        begin
            return matcher.call(result)
        rescue
        end
    end
    return nil 
end

def filterResult(result)
    return result if $settings.regexp.nil?
    match = $settings.regexp.match(result)
    return match[0] if match
    return nil
end

SPINNER = '◐◓◑◒'

def runCommand()
    if $settings.timeout == 0 and !$settings.stop_after_match
        return `#{ARGV.join(" ") }` 
    end

    result = []
    Open3.popen2e(ARGV.join(' ')) do |stdin, stdout, status_thread|
        i = 0
        Timeout.timeout($settings.timeout) do
            stdout.each_line do |line|
                STDERR.print SPINNER[i % SPINNER.size] + "\r"
                i += 1
                result.push(line)
                if $settings.stop_after_match
                    return line if extractNumber(filterResult(line))
                end
            end
        end
    rescue Timeout::Error
        STDERR.puts "# TIMEOUT killing process #{status_thread.pid}"
    ensure
        # Make sure we always kill the subprocess
        begin
            Process.kill('TERM', status_thread.pid)
        rescue
        end
    end
    return result.join('\n')
end

$settings = OpenStruct.new
$settings.runs =  100
$settings.verbose = true 
$settings.regexp = nil
$settings.timeout = 0
$settings.stop_after_match = false

$opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: average [options] COMMAND"
  opts.separator ""
  opts.separator "Example:"
  opts.separator "   average --runs=100 --regexp=user /usr/bin/time sleep 1"
  opts.separator ""
  opts.separator "Options:"

  opts.on_tail("-h", "--help", "Prints this help") do
    puts opts
    exit
  end

  opts.on("-n", "--runs=NAME", Integer, 
          "Set the number of measurement runs, the default is 100") do |n|
      $settings.runs = n
  end

  opts.on("-q", "--quiet", "Don't print stdout/stderr of COMMAND for each run") do
      $settings.verbose = false 
  end

  opts.on("-e", "--regexp=PATTERNS", Regexp, 
          "Set a regexp pattern to filter the COMMAND output (stdout/stderr)") do |regexp|
      $settings.regexp = regexp
  end

  opts.on("-t", "--timeout=TIME", Float, 
          "Kill COMMAND after TIME seconds") do |timeout|
      $settings.timeout = timeout  
  end

  opts.on("-T", "--stop-after-match", 
          "Kill COMMAND after --regexp=PATTERNS matched") do
      $settings.stop_after_match = true
  end
end


def run()
    Signal.trap("INT") { 
      shut_down()
      exit
    }
    Signal.trap("TERM") {
      shut_down()
      exit
    }

    puts ARGV.join(" || ")
    puts "=" * 80
    begin
        for i in 1..$settings.runs do
            label = i.to_s.rjust(2, '0')
            result = filterResult(runCommand())
            if $settings.verbose
                STDERR.puts("# RUN: #{label} OUTPUT: #{result}")
            end
            result = extractNumber(result)
            if result.is_a? Float
                print "# RUN: #{label} RESULT: #{result}\r" 
                $results.push(result)
            else
                print "# RUN: #{label} NO result\r" 
            end
        end
    rescue Interrupt, SignalException
        # ignorr
    rescue => error 
        STDERR.puts error.message
        STDERR.puts error.backtrace
    else 
        shut_down()
    end
end

begin
    $opt_parser.order! ARGV
rescue OptionParser::InvalidOption => error
    puts error
    puts $opt_parser
else
    run
end
