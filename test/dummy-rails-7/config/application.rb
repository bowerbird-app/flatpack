# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "flat_pack"

module DummyRails7
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.1
    config.load_defaults 7.1

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Add FlatPack asset paths for Propshaft
    config.assets.paths << FlatPack::Engine.root.join("app/assets/stylesheets")
  end
end
