#!/usr/bin/env ruby

require 'socket'
require_relative 'android/android_completions'
require_relative 'android/android_bridgesupport_reader'
require_relative 'snippet'


def process_omni_snippets
  omni_snippets = Hash.new { |h,k| h[k] = [] }
  snippets = AndroidCompletions.instance.omni_snippets
  snippets.each do |snippet|
    snippet.signature =~ /(.+)\.(.+)/
    unless $1.nil?
      omni_snippets[$1] << snippet
    else
      omni_snippets["dumb"] << snippet
    end
  end
  omni_snippets
end


instance = AndroidCompletions.instance
instance.read_snippets
class_heirarchy = instance.class_heirarchy
omni_snippets = process_omni_snippets
puts "Started"

server = TCPServer.open(2000)
loop do
  client = server.accept
  prefix = client.gets.strip.chomp
  completion_type = client.gets.strip.chomp
  complete_sequence = client.gets.strip.chomp
  receiver = client.gets.strip.chomp

  while (buffer_data = client.gets)
    break if buffer_data.chomp.strip == '<<EOF>>'
    p buffer_data.chomp.strip
  end
  if prefix.length < 1
    client.puts '||'
    client.close
    next
  end

  completion_string = ""
  if completion_type == "namespace"
    completion_type = "keyword"
    prefix = complete_sequence + "::" + prefix
    completion_string = Snippet.serialize_snippets_with_prefix(instance.keyword_snippets,prefix)
  elsif completion_type == "omni"
    snippets = eval('instance.'+completion_type+'_snippets')
    current_ancestor = complete_sequence
    loop do
      completion_string += Snippet.serialize_snippets_with_prefix(omni_snippets[current_ancestor],current_ancestor + "." + prefix)
      break if class_heirarchy[current_ancestor].nil?
      current_ancestor = class_heirarchy[current_ancestor]
    end
    current_receiver = receiver
    loop do
      completion_string += Snippet.serialize_snippets_with_prefix(omni_snippets[current_receiver],current_receiver + "." + prefix)
      break if class_heirarchy[current_receiver].nil?
      current_receiver = class_heirarchy[current_receiver]
    end
  end

  if completion_string.nil? || completion_string.gsub("|","") == ""
    completion_string = Snippet.serialize_snippets_with_prefix(omni_snippets["dumb"],prefix)
  end
  client.puts completion_string
  client.close
end

