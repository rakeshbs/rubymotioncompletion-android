require_relative '../parser'

class AndroidStructParser < Parser

  def initialize()
    add_child_parser AndroidFieldParser
  end

  def can_parse?(node)
    node.name == "struct"
  end

  def parse(node)
    struct_name = node.attributes["name"].value
    snippet = Snippet.new do |s|
      s.completion = struct_name
      s.abbreviation = struct_name
      s.type = "s"
      s.hint = ""
      s.signature = struct_name
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)
    node.children.each do |child|
      parse_using_children(child)
    end
  end

end

class AndroidFieldParser < Parser
  def can_parse?(node)
    node.name == "field"
  end

  def parse(node)
    field_name = node.attributes["name"].value
    snippet = Snippet.new do |s|
      s.completion = field_name
      s.abbreviation = field_name
      s.type = "s"
      s.hint = ""
      s.signature = field_name
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)
  end
end
