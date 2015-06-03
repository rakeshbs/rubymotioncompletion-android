require_relative '../parser'
require_relative 'android_method_parser'

class AndroidClassParser < Parser

  def initialize()
    add_child_parser AndroidMethodParser
  end

  def can_parse?(node)
    node.name == 'class' || node.name == 'informal_protocol'
  end

  def parse(node)
    class_name = node.attributes['name'].value
    p class_name
    snippet = Snippet.new do |s|
      s.completion = class_name
      s.abbreviation = class_name
      s.type = 's'
      s.hint = ''
      s.signature = class_name
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)
    node.children.each do |child|
      parse_using_children child
    end
  end
end
