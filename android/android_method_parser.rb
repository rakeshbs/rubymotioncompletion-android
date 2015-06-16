require_relative '../parser'
require 'nokogiri'
require_relative 'android_symbols_dict'

class AndroidMethodParser < Parser

  def parse(node)
    class_name = node.parent.attributes['name'].value.gsub("/","::").gsub("$",".")
    method_name = node.attributes['name'].value
    type_attribute = node.attributes['type'].value
    is_class_method = node.attributes['class_method'].value if node.attributes['class_method'] != nil

    return unless type_attribute =~ /\((.*)\)(.*)/
    method_types = $1.split(';')
    return_type = identify_type($2)[0].strip
    return_type = return_type[0..-2] if return_type[-1] == ';'

    method_parameters = []

    method_types.each do |library_string|
      type = identify_type(library_string)
      method_parameters << type unless type.nil?
    end

    method_parameters << return_type
    method_parameters << method_name

    if is_class_method
    else
      snippet = Snippet.new do |s|
        s.completion = method_name + '('
        s.abbreviation = method_name + '('
        s.type = "m"
        s.hint = method_parameters.to_s
        s.signature = method_name
      end
      p snippet
      AndroidCompletions.instance.add_omni_snippet(snippet)
    end


    #puts method_parameters.join(";")
  end

  def identify_type(type_string)
    return [] if type_string == nil
    return [] if type_string.strip.chomp == ''
    if type_string[0] == 'L'
      return [type_string.split('/')[-1]]
    else
      if type_string[0] == '['
        return identify_type(type_string[1..-1])[-1] + "[]"
      else
        return identify_type(type_string[1..-1]) << @@android_types[type_string[0]]
      end
    end
    []
  end

  def can_parse?(node)
    node.name == "method"
  end
end
