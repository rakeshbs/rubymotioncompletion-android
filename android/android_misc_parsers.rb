require_relative '../parser'

class AndroidConstantParser < Parser

  def can_parse?(node)
    node.name == 'constant'
  end

  def parse(node)
    constant_name = node.attributes['name'].value
    snippet = Snippet.new do |s|
      s.completion = constant_name
      s.abbreviation = constant_name
      s.type = 'c'
      s.hint = ''
      s.signature = constant_name
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)
  end
end

class AndroidEnumParser < Parser

  def can_parse?(node)
    node.name == 'enum'
  end

  def parse(node)
    enum_name = node.attributes['name'].value
    snippet = Snippet.new do |s|
      s.completion = enum_name
      s.abbreviation = enum_name
      s.type = 'e'
      s.hint = ''
      s.signature = enum_name
    end
    AndroidCompletions.instance.add_keyword_snippet(snippet)
  end
end
