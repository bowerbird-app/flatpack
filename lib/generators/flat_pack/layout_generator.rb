# frozen_string_literal: true

require "rails/generators/base"

module FlatPack
  module Generators
    class LayoutGenerator < Rails::Generators::Base
      source_root File.expand_path("templates/layout", __dir__)

      desc "Generate FlatPack application layout scaffolds"

      class_option :type,
        type: :string,
        default: "sidebar",
        desc: "Layout type to generate (currently supported: sidebar)"

      class_option :layout_name,
        type: :string,
        default: "flat_pack_sidebar",
        desc: "Layout filename to create under app/views/layouts"

      class_option :side,
        type: :string,
        default: "left",
        desc: "Sidebar side (left or right)"

      class_option :storage_key,
        type: :string,
        default: "flat-pack-sidebar-layout",
        desc: "localStorage key used by FlatPack::SidebarLayout::Component"

      def validate_options
        unless supported_layout_types.include?(layout_type)
          raise Thor::Error, "Unsupported layout type '#{options[:type]}'. Supported types: #{supported_layout_types.join(", ")}"
        end

        return if supported_sides.include?(sidebar_side)

        raise Thor::Error, "Unsupported side '#{options[:side]}'. Supported sides: #{supported_sides.join(", ")}"
      end

      def generate_layout_files
        case layout_type
        when "sidebar"
          template "sidebar_layout.html.erb.tt", "app/views/layouts/#{normalized_layout_name}.html.erb"
          template "_sidebar.html.erb.tt", "app/views/layouts/flat_pack/_sidebar.html.erb"
          template "_top_nav.html.erb.tt", "app/views/layouts/flat_pack/_top_nav.html.erb"
        end
      end

      def show_next_steps
        say "\n✓ Generated FlatPack #{layout_type} layout scaffold", :green
        say "\nNext steps:", :cyan
        say "  1. Use the generated layout in a controller:", :cyan
        say "     class ApplicationController < ActionController::Base", :cyan
        say "       layout \"#{normalized_layout_name}\"", :cyan
        say "     end", :cyan
        say "  2. Update app/views/layouts/flat_pack/_sidebar.html.erb with your app routes", :cyan
        say "  3. Update app/views/layouts/flat_pack/_top_nav.html.erb with your app actions", :cyan
      end

      private

      def supported_layout_types
        %w[sidebar]
      end

      def supported_sides
        %w[left right]
      end

      def layout_type
        options[:type].to_s.strip.downcase
      end

      def sidebar_side
        options[:side].to_s.strip.downcase
      end

      def normalized_layout_name
        options[:layout_name].to_s.strip.sub(/\.html\.erb\z/, "")
      end
    end
  end
end