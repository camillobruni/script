#!/usr/bin/env ruby

$results = []
def shut_down
    avg = $results.inject{ |sum, el| sum + el }.to_f / $results.size
    puts("=" * 50)
    puts("avg = #{avg}")
end


begin
    for i in 0..100 do
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
