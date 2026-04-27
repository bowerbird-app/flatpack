# frozen_string_literal: true

app_platform_gemfile = File.expand_path("../Gemfile.app_platform", __dir__)
dummy_gemfile = File.expand_path("../Gemfile", __dir__)
root_gemfile = File.expand_path("../../../Gemfile", __dir__)

ENV["BUNDLE_GEMFILE"] ||= if File.exist?(dummy_gemfile)
  if ENV["RAILS_ENV"] == "production" && File.exist?(app_platform_gemfile)
    app_platform_gemfile
  else
    dummy_gemfile
  end
else
  root_gemfile
end

require "bundler/setup" # Set up gems listed in the Gemfile.
