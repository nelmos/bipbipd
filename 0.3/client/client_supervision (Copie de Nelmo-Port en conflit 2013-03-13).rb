#!/usr/bin/ruby

server = '127.0.0.2'
port = 5666


require 'socket'

socket = TCPSocket.open(server, port)
socket.puts "-rt=active|-chk=check_ram.sh|-args=50!30|-rly=0|"
while line = socket.gets
  puts line
end

socket.close
