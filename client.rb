require 'socket'
require_relative 'snippet'

hostname = '127.0.0.1'
port = 2000
server = TCPSocket.open(hostname, port)
server.puts ARGV[0]
server.puts "omni"
server.puts ""
server.puts ""
server.puts "<<EOF>>"
completions = server.gets
snippets = Snippet.deserialize_snippets(completions)
snippets.each do |s|
  s.print
end
server.close


