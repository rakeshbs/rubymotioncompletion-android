require_relative '../parser'
require_relative 'android_completions'
require_relative 'android_method_parser'

class AndroidClassParser < Parser

  def initialize()
    add_child_parser AndroidMethodParser
  end

  def can_parse?(node)
    node.name == 'class'
  end

  def parse(node)
    class_name = node.attributes['name'].value
    super_class = node.attributes['super'].value unless node.attributes['super'].nil?
    namespaces = class_name.split(/[$\/]/)
    prefix = ""
    namespaces.each.with_index do |namespace,index|
      prefix += namespace[0].upcase + namespace[1..-1]
      snippet = Snippet.new do |s|
        s.completion = namespace[0].upcase + namespace[1..-1]
        s.abbreviation = prefix
        s.type = 'c'
        s.hint = ''
        s.signature = s.abbreviation
      end
      AndroidCompletions.instance.add_keyword_snippet(snippet)
      prefix += "::"
    end

    unless super_class.nil?
      AndroidCompletions.instance.add_class_and_super_class(format_namespaces(class_name),
                                                            format_namespaces(super_class))
    end

    node.children.each do |child|
      parse_using_children child
    end
  end

  def format_namespaces(class_name)
    namespaces = class_name.split(/[$\/]/)
    namespaces.map { |namespace| namespace[0].upcase + namespace[1..-1]}.join("::")
  end
end
