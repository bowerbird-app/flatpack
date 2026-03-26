# frozen_string_literal: true

dummy_gemfile = File.expand_path("../Gemfile", __dir__)
root_gemfile = File.expand_path("../../../Gemfile", __dir__)

ENV["BUNDLE_GEMFILE"] ||= if File.exist?(dummy_gemfile)
  dummy_gemfile
else
  root_gemfile
end

require "bundler/setup"
