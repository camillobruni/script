#!/usr/bin/env ruby

module Enumerable
    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
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
    stdevPercentage = (100.0 * stdev / mean).round(2)
    puts("=" * 50)
    puts("avg = #{$results.mean}")
    puts("result = #{meanRounded} +/- #{stdevRounded}(#{stdevPercentage}%)")
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
    shut_down()
rescue Exception
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
