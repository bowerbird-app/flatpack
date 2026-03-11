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

      def configure_importmap
        importmap_path = Rails.root.join("config/importmap.rb")

        if File.exist?(importmap_path)
          content = File.read(importmap_path)

          # Check if already configured
          if content.include?("controllers/flat_pack") && content.include?("flat_pack/controllers") && content.include?("@tiptap/core")
            say "\n⊙ Importmap already configured for FlatPack controllers", :yellow
            return
          end

          pin_config = []
          unless content.include?("controllers/flat_pack") && content.include?("flat_pack/controllers")
            pin_config << "\n# Pin FlatPack controllers without modulepreload for lazy loading\npin_all_from FlatPack::Engine.root.join(\"app/javascript/flat_pack/controllers\"), under: \"controllers/flat_pack\", to: \"flat_pack/controllers\", preload: false\n"
          end

          unless content.include?("@tiptap/core")
            pin_config << "\n# Built-in TipTap rich text dependencies\n#{tiptap_importmap_pins}\n"
          end

          File.write(importmap_path, content + pin_config.join)

          say "\n✓ Configured importmap for FlatPack controllers", :green
          say "  - Added pin_all_from for controllers/flat_pack with preload: false", :green
          say "  - Added built-in TipTap rich text pins", :green if pin_config.any? { |entry| entry.include?("@tiptap/core") }
        else
          say "\n⊙ Importmap configuration file not found", :yellow
          say "  If using importmaps, manually add to config/importmap.rb:", :yellow
          say "  pin_all_from FlatPack::Engine.root.join(\"app/javascript/flat_pack/controllers\"), under: \"controllers/flat_pack\", to: \"flat_pack/controllers\", preload: false", :cyan
          say "  #{tiptap_importmap_pins.lines.first.strip}", :cyan
        end
      end

      def configure_stimulus_controllers
        controllers_index_path = Rails.root.join("app/javascript/controllers/index.js")

        if File.exist?(controllers_index_path)
          content = File.read(controllers_index_path)

          # Check if already configured
          if content.include?("controllers/flat_pack")
            say "\n⊙ Stimulus already configured for FlatPack controllers", :yellow
            return
          end

          content = ensure_lazy_stimulus_loader_import(content)

          # Add lazy loading for FlatPack controllers
          flat_pack_config = "\n// Lazy load FlatPack controllers on first use\nlazyLoadControllersFrom(\"controllers/flat_pack\", application)\n"

          File.write(controllers_index_path, content + flat_pack_config)

          say "\n✓ Configured Stimulus for FlatPack controllers", :green
          say "  - Added lazyLoadControllersFrom for controllers/flat_pack", :green
        else
          say "\n⊙ Stimulus controllers index not found", :yellow
          say "  If using Stimulus, manually add to app/javascript/controllers/index.js:", :yellow
          say "  import { lazyLoadControllersFrom } from \"@hotwired/stimulus-loading\"", :cyan
          say "  lazyLoadControllersFrom(\"controllers/flat_pack\", application)", :cyan
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
          new_content = content[0...insert_position] + "\n" + config_content + "\n" + content[insert_position..]

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

      def ensure_lazy_stimulus_loader_import(content)
        import_pattern = /import\s*\{\s*([^}]+)\s*\}\s*from\s*["']@hotwired\/stimulus-loading["']/

        match = content.match(import_pattern)
        if match
          imported_symbols = match[1].split(",").map(&:strip)
          return content if imported_symbols.include?("lazyLoadControllersFrom")

          updated_symbols = (imported_symbols + ["lazyLoadControllersFrom"]).uniq.join(", ")
          return content.sub(import_pattern, "import { #{updated_symbols} } from \"@hotwired/stimulus-loading\"")
        end

        "import { lazyLoadControllersFrom } from \"@hotwired/stimulus-loading\"\n" + content
      end

      def show_next_steps
        say "\n" + "=" * 70, :cyan
        say "Next Steps", :green
        say "=" * 70, :cyan
        say "\n1. Restart your Rails server"
        say "2. Rebuild Tailwind CSS (if needed):"
        say "   bin/rails tailwindcss:build"
        say "\n3. Verify JavaScript controllers are working:"
        say "   Check browser console for any controller loading errors"
        say "\n4. TipTap rich text is now built in:"
        say "   render FlatPack::TextArea::Component.new(name: \"post[body]\", rich_text: true)"
        say "\n5. Test FlatPack components in your views:"
        say "   <%= render FlatPack::Button::Component.new("
        say "     label: 'Click me',"
        say "     scheme: :primary"
        say "   ) %>\n"
        say "\nDocumentation: docs/", :cyan
        say "=" * 70, :cyan
      end

      def tiptap_importmap_pins
        <<~RUBY.chomp
          pin "@tiptap/core", to: "https://esm.sh/@tiptap/core?bundle"
          pin "@tiptap/starter-kit", to: "https://esm.sh/@tiptap/starter-kit?bundle"
          pin "@tiptap/extension-placeholder", to: "https://esm.sh/@tiptap/extension-placeholder?bundle"
          pin "@tiptap/extension-character-count", to: "https://esm.sh/@tiptap/extension-character-count?bundle"
          pin "@tiptap/extension-link", to: "https://esm.sh/@tiptap/extension-link?bundle"
          pin "@tiptap/extension-underline", to: "https://esm.sh/@tiptap/extension-underline?bundle"
          pin "@tiptap/extension-highlight", to: "https://esm.sh/@tiptap/extension-highlight?bundle"
          pin "@tiptap/extension-text-style", to: "https://esm.sh/@tiptap/extension-text-style?bundle"
          pin "@tiptap/extension-color", to: "https://esm.sh/@tiptap/extension-color?bundle"
          pin "@tiptap/extension-text-align", to: "https://esm.sh/@tiptap/extension-text-align?bundle"
          pin "@tiptap/extension-bubble-menu", to: "https://esm.sh/@tiptap/extension-bubble-menu?bundle"
          pin "@tiptap/extension-floating-menu", to: "https://esm.sh/@tiptap/extension-floating-menu?bundle"
          pin "@tiptap/extension-task-list", to: "https://esm.sh/@tiptap/extension-task-list?bundle"
          pin "@tiptap/extension-task-item", to: "https://esm.sh/@tiptap/extension-task-item?bundle"
          pin "@tiptap/extension-image", to: "https://esm.sh/@tiptap/extension-image?bundle"
          pin "@tiptap/extension-table", to: "https://esm.sh/@tiptap/extension-table?bundle"
          pin "@tiptap/extension-table-row", to: "https://esm.sh/@tiptap/extension-table-row?bundle"
          pin "@tiptap/extension-table-header", to: "https://esm.sh/@tiptap/extension-table-header?bundle"
          pin "@tiptap/extension-table-cell", to: "https://esm.sh/@tiptap/extension-table-cell?bundle"
        RUBY
      end
    end
  end
end
