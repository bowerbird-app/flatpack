# frozen_string_literal: true

require "rails/generators/base"

module FlatPack
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install FlatPack into your application"

      def add_stylesheet_import
        app_css_path = Rails.root.join("app/assets/stylesheets/application.css")

        if File.exist?(app_css_path)
          css_content = File.read(app_css_path)
          import_statement = '@import "flat_pack/variables.css";'

          if css_content.include?(import_statement)
            say "⊙ FlatPack stylesheet import already exists in application.css", :yellow
          else
            # Add import at the top, after any @layer directives
            if css_content.include?("@import")
              # Add after existing imports
              prepend_to_file app_css_path, "#{import_statement}\n"
            else
              # Add at the very top
              prepend_to_file app_css_path, "#{import_statement}\n\n"
            end

            say "✓ Added FlatPack stylesheet import to application.css", :green
          end
        else
          say "✗ Could not find app/assets/stylesheets/application.css", :red
          say "  Please manually add: @import \"flat_pack/variables.css\";", :yellow
        end
      end

      def show_tailwind_instructions
        say "\n" + "=" * 70, :cyan
        say "FlatPack Installation Complete!", :green
        say "=" * 70, :cyan
        say "\nTo enable Tailwind CSS 4 to scan FlatPack components, add this to your"
        say "app/assets/stylesheets/application.css file:\n\n", :yellow
        say '  /* @source "../../../.bundle/ruby/*/gems/flat_pack-*/app/components" */'
        say "\nOr for a specific Bundler path:\n\n", :yellow
        say '  /* @source "../../gems/flat_pack-0.1.0/app/components" */'
        say "\nFor more information, see: docs/installation.md", :cyan
        say "=" * 70, :cyan
      end

      def show_next_steps
        say "\nNext steps:", :green
        say "  1. Restart your Rails server"
        say "  2. Use components in your views:"
        say "     <%= render FlatPack::Button::Component.new(label: 'Click me', scheme: :primary) %>"
        say "\nDocumentation: docs/", :cyan
      end
    end
  end
end
