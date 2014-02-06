#!/usr/bin/env ruby

# ----------------------------------------------------------------------------

$KCODE = 'UTF-8' if RUBY_VERSION < '1.9.0'

require 'rubygems'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'pp'
require 'pry'
require 'pry-nav'
require 'pry-stack_explorer'

# ----------------------------------------------------------------------------
# Emulating javascript's escape behaviour

EncodeMap = "ä-Ä-ö-Ö-ü-Ü-è-à-é-â-ê- ".split("-").zip(
      "%E4-%C4-%F6-%D6-%FC-%DC-%E8-%E0-%E9-%E2-%EA-%20".split('-'))

class String
    def urlencode()
        self.split(//).map{|f|
            a = EncodeMap.assoc(f)
            if not a.nil?
                a[1]
            else
                f
            end
        }.join('')
    end
end

# ----------------------------------------------------------------------------
class TextTable
    def initialize
        @rows = []
        @row_widths = []
    end

    def add_row(row=[])
        row = row.map{|f| f.strip()}
        @rows.push(row)
        self.update_row_widths(row)
    end

    def update_row_widths(row)
        return if row.nil?
        (0..row.size-1).each { |i|
            row[i] = '' if row[i].nil?
            if @row_widths[i].nil?
                @row_widths[i] = row[i].size
            else
                @row_widths[i] = [@row_widths[i], row[i].size].max
            end
            @row_widths[i] = 0 if @row_widths.nil? 
        }
    end

    def to_s(separator=' ')
        s = ''
        @rows.each { |row|
            (0..row.size-1).each { |i|
                row[i] = '' if row[i].nil?
                s += row[i].strip.ljust(@row_widths[i])
                s += separator
            }
            s += "\n"
        }
        return s
    end
end


# ----------------------------------------------------------------------------
def open_sbb(from, to, time=nil, isDepartureTime=true, date=nil)
    time = sbb_get_time(time)
    date = sbb_get_date(date)
    departure = isDepartureTime ? 'depart' : 'arrive'
    url = URI.parse("http://fahrplan.sbb.ch/bin/query.exe/dn?" +
        "_charset_=UTF-8&" +
        "start=1&" +
        "S=#{from.urlencode}&" +
        "Z=#{to.urlencode}&" +
        "date=#{date.urlencode}&" +
        "time=#{time.urlencode}&" +
        "timesel=#{departure.urlencode}")
    if ENV['http_proxy']
        proxy = URI.parse(ENV['http_proxy'])
        res = Net::HTTP::Proxy(proxy.host, proxy.port).get(url)
    else
        res = Net::HTTP.get(url)
    end
    sbb_parse_html_results(res) 
end


def sbb_parse_html_results(html)
  File.open('foo.html','w+'){|f| f.write(html)}
    doc = Nokogiri::HTML(html)
    entries = doc.xpath('//tr[@class="overview "]') # NOTE: the space is on purpose
    
    table = TextTable.new
    table.add_row(['Station', '',     'Time', '', 'Dur.', 'Chng.', 'Type'])
    entries.each_slice(2) { |el|
        row = el[0].elements.collect {|node|
          node.text.strip
        }
        table.add_row([row[2], row[4], row[5], '', row[7], ' '+row[8], row[9]])
        
        row = el[1].elements.collect {|node|
          node.text.strip
        }
        table.add_row([row[1], row[3], row[4], '', '', '', ''])
        table.add_row()
    }
    puts table.to_s
end


def sbb_get_time(time)
    return Time.now.strftime("%H%M") if time.nil? or time == 'now'
    if time.start_with? '+' or time.start_with? '-'
        direction = time.start_with?('-') ? -1 : 1
        delta = time[1..-1]
        sec, min, hour = Time.now.to_a
        if delta.end_with? 'm'
            min += direction * delta[0..-1].to_i
            if min >= 60
                hour += (min / 60).floor
            elsif min < 0
                hour += (min / 60).ceil
            end
            min = (min + 60) % 60
        elsif delta.end_with? 'd'
            hour = (hour + direction * delta.to_i + 24) % 24  
        else
            hour = (hour + direction * delta.to_i + 24) % 24  
        end
        return hour.to_s + min.to_s
    end
    return time
end


def sbb_get_date(date)
    return Time.now.strftime("%d.%m.%Y") if date.nil? or date == 'now'
    if date.start_with? '+'
        sec, min, hour, day, month, year = Time.now.to_a
        delta = date[1..-1]
        if delta.end_with? 'y'
             year += delta[0..-1].to_i  
        elsif delta.end_with? 'm'
             month += delta[0..-1].to_i
        elsif delta.end_with? 'd'
            day += delta[0..-1].to_i
        else
            day += delta.to_i 
        end
        return Time.mktime(year, month, day).strftime("%d.%m.%Y")
    end
    return date
end


# ----------------------------------------------------------------------------
if __FILE__ == $0
    if $*.size == 1
        if $*[0] == "--hack"
            exec("sudo vim #{__FILE__}")
        end
    elsif $*.size == 0
        puts <<DOC
This is a simple script to query the timetable of http://sbb.ch/

EXAMPLE:
    sbb bern zürich
    sbb bern zürich +2h +2d
    sbb bern zürich a 12:00 30.01.2010

USAGE:
    sbb FROM TO
    sbb FROM TO TIME
    sbb FROM TO TIME DATE
    
    FROM: Departure place
    TO:   Destination place
    TIME: [a|d](00:00 | (+|-)00[m|h])
          a: Arrival time
          d: Departure Time
    DATE: 00.00.0000 | (+|-)00[m|d]

DOC
        exit
    end

    from = ARGV.shift
    to = ARGV.shift
    time = ARGV.shift
    if ['a', 'arr', 'an'].member? time
        isDepartureTime = false
        time = ARGV.shift
    elsif ['d', 'dep', 'ab'].member? time
        isDepartureTime = true
        time = ARGV.shift
    end
    date = ARGV.shift
    open_sbb(from, to, time, isDepartureTime, date)
end 
