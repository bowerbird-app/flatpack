# frozen_string_literal: true

require "rails/generators/base"
require "pathname"

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

      def configure_tailwind_css_4
        # Check for common Tailwind CSS 4 file locations
        tailwind_paths = [
          Rails.root.join("app/assets/stylesheets/application.tailwind.css"),
          Rails.root.join("app/assets/stylesheets/application.css"),
          Rails.root.join("app/assets/tailwind/application.css")
        ]

        tailwind_file = tailwind_paths.find { |path| File.exist?(path) && uses_tailwind_css_4?(path) }

        if tailwind_file
          configure_tailwind_file(tailwind_file)
        else
          show_manual_tailwind_instructions
        end
      end

      private

      def uses_tailwind_css_4?(file_path)
        content = File.read(file_path)
        # Tailwind CSS 4 uses @import "tailwindcss" instead of @tailwind directives
        content.include?('@import "tailwindcss"') || content.include?("@import 'tailwindcss'")
      end

      def configure_tailwind_file(tailwind_file)
        content = File.read(tailwind_file)
        
        # Check if already configured
        if (content.include?("@source") && content.include?("flat_pack")) || content.include?("flatpack")
          say "\n⊙ Tailwind CSS 4 already configured for FlatPack", :yellow
          return
        end

        # Get the gem path
        gem_path = get_gem_path
        unless gem_path
          say "\n✗ Could not determine FlatPack gem path", :red
          show_manual_tailwind_instructions
          return
        end

        # Calculate relative path from Tailwind file to gem components
        relative_path = calculate_relative_path(tailwind_file, gem_path)
        
        # Read the template and inject the source path
        template_content = File.read(File.expand_path("templates/tailwind_config.css.tt", __dir__))
        config_content = template_content.gsub("<%= source_path %>", relative_path)

        # Find the position to insert (after @import "tailwindcss")
        if content =~ /(@import\s+["']tailwindcss["'];?\s*\n)/
          insert_position = content.index($1) + $1.length
          
          # Insert the configuration
          new_content = content[0...insert_position] + "\n" + config_content + "\n" + content[insert_position..-1]
          
          File.write(tailwind_file, new_content)
          
          say "\n✓ Configured Tailwind CSS 4 for FlatPack", :green
          say "  - Added @source directive: #{relative_path}", :green
          say "  - Added @theme block with FlatPack design tokens", :green
          say "  - Added :root mappings for component compatibility", :green
          say "\n  File updated: #{tailwind_file.relative_path_from(Rails.root)}", :cyan
        else
          say "\n✗ Could not find @import \"tailwindcss\" in #{tailwind_file.relative_path_from(Rails.root)}", :red
          show_manual_tailwind_instructions
        end
      end

      def get_gem_path
        # Try using Bundler to get the gem path
        begin
          gem_spec = Gem::Specification.find_by_name("flat_pack")
          return Pathname.new(gem_spec.gem_dir).join("app/components")
        rescue Gem::MissingSpecError
          # Gem not found in standard location, try bundler
          begin
            require "bundler"
            bundle_path = Bundler.bundle_path
            
            # Look for the gem in bundler's path
            flat_pack_dirs = Dir.glob(bundle_path.join("**/flat_pack-*").to_s)
            
            if flat_pack_dirs.any?
              # Get the first match (should only be one)
              gem_dir = Pathname.new(flat_pack_dirs.first)
              return gem_dir.join("app/components")
            end
          rescue => e
            say "  Debug: Error finding gem path: #{e.message}", :red if ENV["DEBUG"]
          end
        end
        
        nil
      end

      def calculate_relative_path(from_file, to_path)
        # Get the directory containing the from_file
        from_dir = from_file.dirname
        
        # Calculate the relative path
        relative = to_path.relative_path_from(from_dir)
        
        relative.to_s
      end

      def show_manual_tailwind_instructions
        say "\n" + "=" * 70, :cyan
        say "Manual Tailwind CSS 4 Configuration Required", :yellow
        say "=" * 70, :cyan
        say "\nTo enable Tailwind CSS 4 to scan FlatPack components:"
        say "\n1. Find your FlatPack gem path:"
        say "   bundle show flat_pack\n"
        say "\n2. Add this configuration to your Tailwind CSS file"
        say "   (typically app/assets/stylesheets/application.tailwind.css):\n"
        say '   @source "../path/to/flat_pack/app/components";'
        say "\n   @theme {"
        say "     --color-fp-primary: oklch(0.52 0.26 250);"
        say "     /* ... other FlatPack design tokens ... */"
        say "   }"
        say "\n   :root {"
        say "     --color-primary: var(--color-fp-primary);"
        say "     /* ... other mappings ... */"
        say "   }\n"
        say "\nFor complete configuration, see: docs/installation.md", :cyan
        say "=" * 70, :cyan
      end

      def show_next_steps
        say "\n" + "=" * 70, :cyan
        say "Next Steps", :green
        say "=" * 70, :cyan
        say "\n1. Restart your Rails server"
        say "2. Rebuild Tailwind CSS (if needed):"
        say "   bin/rails tailwindcss:build"
        say "\n3. Test FlatPack components in your views:"
        say "   <%= render FlatPack::Button::Component.new("
        say "     label: 'Click me',"
        say "     scheme: :primary"
        say "   ) %>\n"
        say "\nDocumentation: docs/", :cyan
        say "=" * 70, :cyan
      end
    end
  end
end
