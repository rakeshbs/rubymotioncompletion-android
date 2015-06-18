require 'singleton'
require 'yaml'
require_relative '../snippet'
require_relative 'android_bridgesupport_reader'

class AndroidCompletions
  include Singleton

  attr_accessor :omni_snippets, :keyword_snippets, :class_heirarchy

  def add_keyword_snippet(snippet)
    unless @keyword_snippets.include?(snippet)
      keyword_snippets << snippet
    end
  end

  def add_omni_snippet(snippet)
    unless @omni_snippets.include?(snippet)
      omni_snippets << snippet
    end
  end

  def add_class_and_super_class(class_name,super_class)
    @class_heirarchy[class_name] = super_class
  end


  def create_snippet_from_bridgesupport(version=nil)
    read_android_bridgesupport(version)
  end

  def save_snippets
    omni_snippets.sort()
    keyword_snippets.sort()

    keywords = Snippet.serialize_snippets_with_prefix(keyword_snippets,"")
    omni = Snippet.serialize_snippets_with_prefix(omni_snippets,"")


    File.open('android_keyword.snippets','w') do |f|
      f.write keywords
    end

    File.open('android_omni.snippets','w') do |f|
      f.write omni
    end

    File.open("android_class_heirarchy.yml", "w") do |file|
      file.write @class_heirarchy.to_yaml
    end

  end

  def read_snippets
    File.open('android_keyword.snippets','r') do |f|
      keywords = f.read
      @keyword_snippets = Snippet.deserialize_snippets(keywords)
    end

    File.open('android_omni.snippets','r') do |f|
      omnis = f.read
      @omni_snippets = Snippet.deserialize_snippets(omnis)
    end

    if File.exists?('android_class_heirarchy.yml')
      @class_heirarchy = YAML::load_file "android_class_heirarchy.yml"
    end

  end

  def initialize
    @omni_snippets ||= []
    @keyword_snippets ||= []
    @class_heirarchy ||= {}
  end
end
