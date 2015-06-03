require_relative '../parser'
require 'nokogiri'
require_relative 'android_completions'

class AndroidMethodParser < Parser
  def parse(node)
    method_name = node.attributes['selector'].value
    return_value = nil
    argument_names = []
    argument_types = []
    node.children.each do |child|
      if child.name == "arg"
        argument_type = child.attributes["declared_type"].value
        argument_index = child.attributes["index"].value
        argument_name = child.attributes["name"].value

        index = argument_index.to_i
        argument_names[index] = argument_name
        argument_types[index] = argument_type

      elsif child.name == "retval"
        return_value = child.attributes["declared_type"].value
      end
    end
    method_split = method_name.split(":")

    completion = get_completion_with_separator(method_split,argument_types.length) do |i|
      "<%>"
    end

    abbreviation = get_completion_with_separator(method_split,argument_types.length) do |i|
      argument_types[i]
    end

    snippet = Snippet.new() do |s|
      s.completion = completion
      s.abbreviation = abbreviation
      s.type = "m"
      s.hint = "returns #{return_value}"
      s.signature = method_name
    end

    AndroidCompletions.instance.add_omni_snippet(snippet)
  end

  def get_completion_with_separator(method_split,argument_count,&block)
    completion = method_split[0]
    if (argument_count > 0)
      completion += "("+block.call(0)
      1.upto(argument_count-1) do |i|
        completion += ", #{method_split[i]}:"+block.call(i)
      end
      completion += ")"
    end
    completion
  end

  def can_parse?(node)
    node.name == "method"
  end
end
