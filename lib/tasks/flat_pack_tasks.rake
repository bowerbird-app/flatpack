# frozen_string_literal: true

namespace :flat_pack do
  desc "Display FlatPack version"
  task :version do
    puts "FlatPack version: #{FlatPack::VERSION}"
  end

  desc "Display FlatPack information"
  task :info do
    puts "FlatPack UI Component Library"
    puts "Version: #{FlatPack::VERSION}"
    puts "Rails: #{Rails.version}"
    puts "Ruby: #{RUBY_VERSION}"
    puts "\nComponents:"
    puts "  - Button (primary, secondary, ghost schemes)"
    puts "  - Table (with columns and actions)"
    puts "  - Icon (shared icon component)"
    puts "\nDocumentation: docs/"
  end
end
