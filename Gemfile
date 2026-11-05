# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in flat_pack.gemspec
gemspec

gem "puma"

# For the dummy application
gem "devise"
gem "pg", "~> 1.1"
gem "propshaft", "~> 1.0"
gem "tailwindcss-rails", "~> 4.0"
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"

group :development, :test do
  gem "debug"
  # Ruby 4 no longer ships ostruct as a default gem. Dummy fixtures and a few tests use it.
  gem "ostruct"
  gem "rubocop"
  gem "rubocop-discourse"
  gem "rubocop-rake"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
end
