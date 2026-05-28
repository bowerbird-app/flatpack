# frozen_string_literal: true

require "rails"
require "view_component/errors"
require "view_component"
require "view_component/slotable"
require "tailwind_merge"

if defined?(ViewComponent::Slotable) &&
    !ViewComponent::Slotable.private_method_defined?(:set_slot) &&
    !ViewComponent::Slotable.private_method_defined?(:get_slot)
  module ViewComponent
    module Slotable
      private

      def set_slot(slot_name, slot_definition = nil, *args, **kwargs, &block)
        __vc_set_slot(slot_name, slot_definition, *args, **kwargs, &block)
      end

      def get_slot(slot_name)
        __vc_get_slot(slot_name)
      end

      def set_polymorphic_slot(slot_name, poly_type = nil, *args, **kwargs, &block)
        __vc_set_polymorphic_slot(slot_name, poly_type, *args, **kwargs, &block)
      end
    end
  end
end

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
    initializer "flat_pack.view_component", after: "view_component.set_configs" do |app|
      if (Rails.env.development? || Rails.env.test?) && app.config.respond_to?(:view_component)
        app.config.view_component ||= ViewComponent::Config.new
        app.config.view_component.previews.paths << root.join("test/components/previews").to_s
      end
    end

    # Load engine tasks
    rake_tasks do
      load root.join("lib/tasks/flat_pack_tasks.rake")
    end
  end
end
