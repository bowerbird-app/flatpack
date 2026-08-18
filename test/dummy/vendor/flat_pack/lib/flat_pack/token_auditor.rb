# frozen_string_literal: true

require "pathname"

    def scan_globs
      patterns = [
        "app/components/**/*.{rb,erb}",
        "app/javascript/**/*.{js,ts}",
        "app/assets/stylesheets/**/*.css"
      ]

      patterns.flat_map { |pattern| Dir[engine_root.join(pattern)].map { |path| Pathname.new(path) } }
    end
  end
end
