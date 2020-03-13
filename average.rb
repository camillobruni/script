#!/usr/bin/env ruby
# encoding: utf-8

require 'tmpdir'


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

$ticks = " ▁▂▃▄▅▆▇█"

$max = 100
begin
    $max = Integer(ARGV[0])
    ARGV.shift
rescue
end

$results = []
def shut_down
    puts("=" * 79)
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
    puts("avg     = #{$results.mean}")
    puts("geomean = #{$results.geomean}")
    puts("min     = #{minRounded}    max = #{maxRounded}")
    puts("result  = #{meanRounded} +/- #{stdevRounded}(#{stdevPercentage}%)")
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
    scale = (2*$ticks.size() - 1).to_f / (maxCount-minCount)
    buckets = buckets.map{|each| (each * scale).ceil() }
    # upper row:
    print(maxCount.to_s.rjust(4)+" ")
    buckets.each{ |value|
        print($ticks[[0, value - $ticks.size()].max])
    }
    puts("")
    # lower row:
    print(minCount.to_s.rjust(4)+" ")
    buckets.each{ |value|
        print($ticks[[$ticks.size()-1, value].min])
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
            result = matcher.call(result)
        rescue
        end
    end
    print "### USING #{result}\r" 
    return result
end


puts ARGV.join(" || ")
puts "=" * 80
begin
    for i in 0..$max do
        result = `#{ARGV.join(" ")}`
        STDERR.puts("# #{(i+1).to_s.rjust(2, '0')}: #{result}")
        result = extractNumber(result)
        $results.push(result)
    end
rescue Interrupt, SignalException
ensure
    shut_down()
end


Signal.trap("INT") { 
  shut_down()
  exit
}

Signal.trap("TERM") {
  shut_down()
  exit
}
