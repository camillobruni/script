#!/usr/bin/env ruby

require 'open-uri'
require 'uri'
require 'net/http'

# ============================================================================

def help
    $stderr.puts "    usage: translate $LANG_FROM $LANG_TO $WORD"
    $stderr.puts "          --hack     edit the sources of this script"
    $stderr.puts "          -h/--help  show this help text"

end

def editor()
    if ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'vim'
    end
end


# ============================================================================


def translate(text)
    url = $url+'&q='+URI.encode(text)
    
    json = Net::HTTP.get_response(URI.parse url).body
    # check for wrong response
    if json =~ /responseStatus"\s*:\s*200/
        puts json.match('translatedText"\s*:\s*"(.*?)"\},')[1]
    else
        $stderr.puts $*
        $stderr.puts json.match(/responseDetails"\s*:\s*"(.*?)", /)[1]
        exit 1
    end
end

if $0 == __FILE__
    if $*[0] == "--help" || $*[0] == "-h" || $*.size == 0
        help()
        exit 0
    elsif $*[0] == "--hack"
        sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
        exec("#{editor()} #{sourceFile}")
    end

    $url  = 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0'
    $url += '&langpair='+($*.shift) +'%7C'+ ($*.shift)
    if $*.length > 0
        translate $*.join(' ')
    elsif $*.length == 0
        puts <<DOC

This script queries google translations.

EXAMPLES:
    translate de en Guten tag.

USAGE:
    translate FROM TO SENTENCE

    FROM:     Language code for the source language
    TO:       Language code for the destination language
    SENTENCE: String to translate

DOC
    else
        ARGF.each{ |line|
            translate(line)
        }
    end
end
