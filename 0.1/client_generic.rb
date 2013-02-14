#!/usr/bin/ruby

server = 'localhost'
port = 20000


require 'socket'

socket = TCPSocket.open(server, port)
socket.puts "rt=P|relay=0|cmd=[1348349172 ] PROCESS_SERVICE_CHECK_RESULT;vm-test-01;NSCA - TEST;2;That's work|t=30|route=undef"
while line = socket.gets
  puts line
end

socket.close
