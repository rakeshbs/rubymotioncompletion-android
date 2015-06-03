require_relative '../parser'
require 'nokogiri'
require 'set'
require_relative '../config'
require_relative 'android_class_parser'
require_relative 'android_function_parser'
require_relative 'android_completions'
require_relative 'android_struct_parser'
require_relative 'android_misc_parsers'

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
    p filepath
    bridge_doc = Nokogiri::XML(File.open(filepath))
    parser.parse(bridge_doc)
  end

  puts "Reading libraries Done"
end

class AndroidBridgeParser  < Parser
  def initialize
     add_child_parser AndroidClassParser
     add_child_parser AndroidFunctionParser
     add_child_parser AndroidStructParser
     add_child_parser AndroidConstantParser
     add_child_parser AndroidEnumParser
  end

  def parse(node)
    node.css("signatures").each do |signature|
      signature.children.each do |child|
        parse_using_children(child)
      end
    end
  end
end

