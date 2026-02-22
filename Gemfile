# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in flat_pack.gemspec
gemspec

gem "puma"

# For the dummy application
gem "propshaft", "~> 1.0"
gem "tailwindcss-rails", "~> 4.0"
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"

group :development, :test do
  gem "debug"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
