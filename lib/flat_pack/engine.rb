# frozen_string_literal: true

require "rails"
require "view_component"
require "tailwind_merge"

module FlatPack
  class Engine < ::Rails::Engine
    isolate_namespace FlatPack

    # Configure autoload paths for components
    config.autoload_paths << root.join("app/components")
    
    # Configure Propshaft to serve our assets
    initializer "flat_pack.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
      end
    end

    # Configure importmap for JavaScript
    initializer "flat_pack.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
      end
    end

    # Add view component preview paths for development
    initializer "flat_pack.view_component" do |app|
      if (Rails.env.development? || Rails.env.test?) && app.config.respond_to?(:view_component)
        app.config.view_component.preview_paths << root.join("test/components/previews").to_s
      end
    end

    # Load engine tasks
    rake_tasks do
      load root.join("lib/tasks/flat_pack_tasks.rake")
    end
  end
end
