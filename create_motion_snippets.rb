#!/usr/bin/env ruby
require_relative 'android/android_bridgesupport_reader'

instance = AndroidCompletions.instance
instance.create_snippet_from_bridgesupport(ARGV[1])
instance.save_snippets
