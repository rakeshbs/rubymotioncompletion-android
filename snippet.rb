require 'nokogiri'
class Snippet
  include Comparable
  attr_accessor :completion
  attr_accessor :abbreviation
  attr_accessor :type
  attr_accessor :hint
  attr_accessor :signature

  def initialize
    yield self if block_given?
  end

  def count_double_colons(str)
    str.gsub("::","/").count("/")
  end

  def completion_start_with?(prefix)
    @signature.start_with?(prefix) && count_double_colons(@signature) == count_double_colons(prefix)
  end

  def case_insensitive_completion_start_with?(prefix)
    @signature.downcase.start_with?(prefix.downcase) && count_double_colons(@signature) == count_double_colons(prefix)
  end

  def serialize
    @completion + '####' + @abbreviation + '####' + @type + '####' + @hint + '####' + @signature
  end

  def self.deserialize(string)
    snippet = Snippet.new
    snippet.instance_eval do
      @completion,@abbreviation,@type,@hint,@signature = string.split('####')
    end
    snippet
  end

  def <=>(other_snippet)
    return @signature <=> other_snippet.signature
  end

  def self.serialize_snippets_with_prefix(snippets,prefix)
    serialized = snippets.inject('') do |concat,s|
      if prefix == '' || s.completion_start_with?(prefix)
        concat += s.serialize + '||'
      end
      concat
    end
    if serialized == ''
      serialized = snippets.inject('') do |concat,s|
        if prefix == '' || s.case_insensitive_completion_start_with?(prefix)
          concat += s.serialize + '||'
        end
        concat
      end
    end
    serialized += '||'
    serialized
  end

  def self.deserialize_snippets(snippets_string)
    snippet_serial_collection = snippets_string.split('||')
    snippet_serial_collection.inject([]) do |snippets,string|
      snippets << Snippet.deserialize(string) unless string == ''
      snippets
    end
  end

  def print
    puts @signature
  end
end
