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
    snippet = Snippet.new do |s|
      s.completion = class_name.gsub("/","::").gsub("$",".")
      s.abbreviation = s.completion.split(/::|\./)[-1]
      s.type = s.completion
      s.hint = ''
      s.signature = s.completion
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)

    namespaces = class_name.split(/[$\/]/)
    prefix = ""
    namespaces.each.with_index do |namespace,index|
      prefix += namespace
      snippet = Snippet.new do |s|
        s.completion = namespace
        s.abbreviation = prefix
        s.type = 'c'
        s.hint = ''
        s.signature = s.completion
      end
      AndroidCompletions.instance.add_keyword_snippet(snippet)
      #if (index == namespaces.size - 2)
      #prefix += "."
      #else
      prefix += "::"
      #end
    end

    node.children.each do |child|
      parse_using_children child
    end
  end
end
