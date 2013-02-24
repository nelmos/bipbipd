#!/usr/bin/ruby

server = 'localhost'
port = 5666


require 'socket'

socket = TCPSocket.open(server, port)
socket.puts "-rt=active|-chk=check_ram.sh|-args=50:30|-tmo=30|"
while line = socket.gets
  puts line
end

socket.close
