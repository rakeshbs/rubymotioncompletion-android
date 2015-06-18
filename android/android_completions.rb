require 'singleton'
require_relative '../snippet'
require_relative 'android_bridgesupport_reader'

class AndroidCompletions
  include Singleton

  attr_accessor :omni_snippets, :keyword_snippets, :class_method_snippets

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


  def create_snippet_from_bridgesupport(version=nil)
    read_android_bridgesupport(version)
  end

  def save_snippets
    keywords = Snippet.serialize_snippets_with_prefix(keyword_snippets,"")
    omni = Snippet.serialize_snippets_with_prefix(omni_snippets,"")

    File.open('android_keyword.snippets','w') do |f|
      f.write keywords
    end

    File.open('android_omni.snippets','w') do |f|
      f.write omni
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

  end

  def initialize
    @omni_snippets ||= []
    @keyword_snippets ||= []
    @class_method_snippets ||= []
  end
end
