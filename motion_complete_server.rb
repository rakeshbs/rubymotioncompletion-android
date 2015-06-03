#!/usr/bin/env ruby

require 'socket'
require_relative 'ios/ios_completions'
require_relative 'ios/ios_bridgesupport_reader'
require_relative 'snippet'

instance = AndroidCompletions.instance
instance.read_snippets
puts "Started"

server = TCPServer.open(2000)
loop {
  client = server.accept
  prefix = client.gets.strip.chomp
  completion_type = client.gets.strip.chomp
  while (buffer_data = client.gets)
    break if buffer_data.chomp.strip == '<<EOF>>'
    puts buffer_data
  end
  if prefix.length < 1
    client.puts '||'
    client.close
    next
  end
  snippets = eval('instance.'+completion_type+'_snippets')
  completion_string = Snippet.serialize_snippets_with_prefix(snippets,prefix)
  client.puts completion_string
  client.close
}