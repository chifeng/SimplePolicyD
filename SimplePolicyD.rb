#!/usr/bin/env ruby
#Author: Chifeng Qu <chifeng@gmail.com>

require 'socket'
require 'pp'
require 'memcached'
require 'dalli'

server = TCPServer.new("0.0.0.0", 8888)
puts "Listening on 0.0.0.0:8888"

default_value = 100

while true
  Thread.new(server.accept) do |client|
    attr = Hash.new
    while rp = client.gets
        if rp == "\n" then
            break
        end
        rp2 = rp.split(/=/)
        attr[rp2[0]] = rp2[1].chomp
    end
    #/
    cache = Dalli::Client.new("localhost:11211")
    
    sender = attr["sender"]

    if sendcount = cache.get("#{sender}")
        sendcount = sendcount + 1
        cache.set "#{sender}" , sendcount
    else
        cache.set "#{sender}" , 1
    end
    p sender
    p sendcount
    p default_value
    if sendcount.to_i > default_value
        client.write("defer_if_permit Service temporarily unavailable\n")
    else
        client.write("DUNNO\n")
    end

    client.write("\n")
    client.close
  end
end

