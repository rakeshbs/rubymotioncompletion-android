require_relative '../parser'
require 'nokogiri'
require_relative 'android_symbols_dict'

class AndroidMethodParser < Parser

  def parse(node)
    class_name = node.parent.attributes['name'].value.gsub("/","::").gsub("$","::")
    class_name = class_name.split("::").map{ |x| x[0].upcase + x[1..-1] }.join("::")
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

    method_parameters.flatten!

    create_getter_snippet(class_name, method_name, method_parameters.to_s)
    create_setter_snippet(class_name, method_name, method_parameters.to_s)

    full_method_name = method_name
    if is_class_method
      full_method_name = "#{class_name}.#{method_name}"
    elsif method_name == "<init>"
      method_name = "new"
      full_method_name = "#{class_name}.new"
    else
      snippet = create_snippet("#{class_name}.#{method_name}",method_name, method_parameters)
      AndroidCompletions.instance.add_omni_snippet(snippet)
    end
    snippet = create_snippet(full_method_name,method_name, method_parameters)
    AndroidCompletions.instance.add_omni_snippet(snippet)
  end


  def create_snippet(full_method_name,method_name,method_parameters)
      Snippet.new do |s|
        s.signature = format_method_parameters(full_method_name,method_parameters) do |parameter|
          "#{parameter}"
        end
        s.completion = format_method_parameters(method_name,method_parameters) do |parameter|
          "<% #{parameter} >"
        end

        s.abbreviation = format_method_parameters(method_name,method_parameters) do |parameter|
          "#{parameter}"
        end
        s.type = "m"
        s.hint = method_parameters.to_s
      end
  end

  def format_method_parameters(method_name,parameters)
    return_string = method_name + "("
    return_string += parameters.reduce("") do |concat,parameter|
      concat += yield(parameter) + ","
    end
    return_string = return_string[0..-2] if parameters.length > 0
    return return_string + ")"
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

  def create_setter_snippet(class_name,method_name,parameters)
   unless method_name =~ /^set(.+)$/
     return
   end
   setter_name = $1[0].downcase + $1[1..-1] + " = "
   create_accessor(setter_name, "#{class_name}.#{setter_name}", "s", parameters)
   create_accessor(setter_name, setter_name, "s", parameters)
  end

  def create_getter_snippet(class_name,method_name,parameters)
   unless method_name =~ /^get(.+)$/
     return
   end
   getter_name = $1[0].downcase + $1[1..-1]
   create_accessor(getter_name, "#{class_name}.#{getter_name}", "s", parameters)
   create_accessor(getter_name, getter_name, "s", parameters)
  end

  def create_accessor(method_name,signature,type,parameters)
    Snippet.new do |s|
      s.signature = signature
      s.abbreviation = method_name
      s.completion = method_name
      s.type = type
      s.hint = parameters
      AndroidCompletions.instance.add_omni_snippet(s)
    end
  end

  def can_parse?(node)
    node.name == "method"
  end
end
