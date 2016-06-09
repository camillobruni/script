#!/usr/bin/env ruby
# encoding: utf-8

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
    stdev = $results.standard_deviation
    mean = $results.mean
    roundTo =  if stdev == 0.0 then 1 else 10.0**Math::log10(stdev).ceil / 100.0 end
    # Figure out the first non-digit in the standard deviation
    meanRounded = (mean / roundTo).round * roundTo
    stdevRounded = (stdev / roundTo).round * roundTo
    minRounded = ($results.min / roundTo).round * roundTo
    maxRounded = ($results.max / roundTo).round * roundTo
    stdevPercentage = (100.0 * stdev / mean).round(2)
    puts("=" * 50)
    puts("avg = #{$results.mean}")
    puts("geomean = #{$results.geomean}")
    puts("result = #{meanRounded} +/- #{stdevRounded}(#{stdevPercentage}%)")
    printHistogram($results, minRounded, maxRounded)
end

def printHistogram(list, minRounded, maxRounded)
    min,max = list.minmax
    # find the constant factor for a logarithmic distribution of 80 buckets
    minLog = Math.log(min)
    maxLog = Math.log(max)
    logStep = 79 / (maxLog - minLog)
    buckets = [0] * 80
    list.each{ |i|
        bucket = ((Math.log(i) - minLog) * logStep).round()
        buckets[bucket] += 1
    }
    min,max = buckets.minmax
    scale = ($ticks.size() - 1).to_f / (max-min)
    buckets.each{ |value|
        print($ticks[(value * scale).ceil()])
    }
    puts("")
    str = minRounded.to_s
    middleStr = Math.exp((minLog + maxLog) / 2).to_s
    maxStr = maxRounded.to_s
    str += middleStr.center(80-str.size()-maxStr.size(), ' ')
    str += maxStr
    puts(str)
end

begin
    for i in 0..$max do
        result = `#{ARGV.join(" ")}`
        puts("run #{i}: #{result}")
        #  extract float
        begin
            result = result.match(/\d+\.\d+/)[0].to_f
        rescue
            result = result.match(/\d+/)[0].to_f
        end
        $results.push(result)
    end
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
