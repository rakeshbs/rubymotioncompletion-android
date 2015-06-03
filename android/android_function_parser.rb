require_relative '../parser'
require 'nokogiri'
require_relative 'android_completions'

class AndroidFunctionParser < Parser
  def parse(node)
    function_name = node.attributes["name"].value
    arguments = []
    argument_types = []
    return_value = nil
    node.children.each do |child|
      if child.name == "arg"
        argument_type_element = child.attributes["declared_type"]
        argument_name_element = child.attributes["name"]

        argument_type = argument_type_element.value unless argument_type_element.nil?
        argument_name = argument_name_element.value unless argument_name_element.nil?

        arguments << "#{argument_name}"
        argument_types << "#{argument_type}"
      elsif child.name == "retval"
        return_value =  child.attributes["declared_type"].value
      end
    end
    ordered_arguments = []
    ordered_argument_types = []

    arguments.each.with_index do |arg,i|
      ordered_arguments << "<% #{arg} >"
      ordered_argument_types << "#{argument_types[i]}"
    end

    completion = function_name + "(" + ordered_arguments.join(" ,") +")"
    hint = function_name + "(" + ordered_argument_types.join(" ,") +")"

#     puts completion

    snippet = Snippet.new() do |s|
      s.completion = completion
      s.abbreviation = completion
      s.type = "f"
      s.hint = "#{hint} returns #{return_value}"
      s.signature = function_name
    end

    AndroidCompletions.instance.add_keyword_snippet(snippet)
  end

  def can_parse?(node)
    node.name == "function"
  end
end
