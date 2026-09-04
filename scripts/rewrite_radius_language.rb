#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

engine_root = Pathname.new(File.expand_path("..", __dir__))
$LOAD_PATH.unshift(engine_root.join("lib").to_s)

require "flat_pack/radius_language"

GLOBS = [
  "app/components/**/*.{rb,erb}",
  "app/javascript/**/*.{js,ts}",
  "app/assets/stylesheets/**/*.css"
].freeze

changed = 0

GLOBS.each do |pattern|
  Dir[engine_root.join(pattern)].each do |path|
    source = File.read(path)
    rewritten = FlatPack::RadiusLanguage.rewrite(source)
    next if rewritten == source

    File.write(path, rewritten)
    changed += 1
    puts Pathname.new(path).relative_path_from(engine_root)
  end
end

puts "rewrote #{changed} files"
