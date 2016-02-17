#!/usr/bin/env ruby

begin
    sum = 0
    while line=gets
        begin
            value = line.match(/\d+\.\d+/)[0].to_f
        rescue
            value = line.to_f
        end
        sum  += value
    end

    puts(sum)
rescue
end
Signal.trap("INT") { 
  exit
}

Signal.trap("TERM") {
  exit
}
