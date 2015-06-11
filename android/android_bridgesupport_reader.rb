require_relative '../parser'
require 'nokogiri'
require 'set'
require_relative '../config'
require_relative 'android_class_parser'
require_relative 'android_completions'

def get_android_libraries(version)
  libraries = Set.new (android_frameworks(version))
  libraries
end

def read_android_bridgesupport(version=nil)
  version ||= default_android_version
  libraries = get_android_libraries(version)
  parser = AndroidBridgeParser.new

  libraries.each do |lib|
    puts "Processing " + lib
    filepath = [android_base_url,version,"BridgeSupport",lib].join('/')
    bridge_doc = Nokogiri::XML(File.open(filepath))
    parser.parse(bridge_doc)
  end

  puts "Reading libraries Done"
end

class AndroidBridgeParser  < Parser
  def initialize
     add_child_parser AndroidClassParser
  end


  def parse(node)
    node.css("signatures").each do |signature|
      signature.children.each do |child|
        parse_using_children(child)
      end
    end
  end
end

