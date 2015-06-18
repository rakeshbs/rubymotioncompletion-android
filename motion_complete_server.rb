#!/usr/bin/env ruby

require 'socket'
require_relative 'android/android_completions'
require_relative 'android/android_bridgesupport_reader'
require_relative 'snippet'


instance = AndroidCompletions.instance
instance.read_snippets
puts "Started"

server = TCPServer.open(2000)
loop do
  client = server.accept
  prefix = client.gets.strip.chomp
  completion_type = client.gets.strip.chomp
  complete_sequence = client.gets.strip.chomp
  receiver = client.gets.strip.chomp
  p receiver

  while (buffer_data = client.gets)
    break if buffer_data.chomp.strip == '<<EOF>>'
    p buffer_data.chomp.strip
  end
  if prefix.length < 1
    client.puts '||'
    client.close
    next
  end

  if completion_type == "namespace"
    completion_type = "keyword"
    prefix = complete_sequence + "::" + prefix
  elsif completion_type == "omni"
    snippets = eval('instance.'+completion_type+'_snippets')
    completion_string = Snippet.serialize_snippets_with_prefix(snippets,complete_sequence + "." + prefix)
    completion_string += Snippet.serialize_snippets_with_prefix(snippets,receiver + "." + prefix)
  end

  snippets = eval('instance.'+completion_type+'_snippets')
  p completion_string
  if completion_string.nil? || completion_string.gsub("|","") == ""
    completion_string = Snippet.serialize_snippets_with_prefix(snippets,prefix)
  end
  client.puts completion_string
  client.close
end

