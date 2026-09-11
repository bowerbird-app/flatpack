# frozen_string_literal: true

module FlatPack
  module ComponentCatalog
    module DocExamples
      CLASS_TOKEN = /\bFlatPack(?:::[A-Za-z0-9_]+)+\b/
      EXAMPLE_HEADING = /\A## Example\s*\z/
      NEXT_H2 = /\A## /
      FENCE_OPEN = /\A```\s*(\S*)/
      FENCE_CLOSE = /\A```\s*\z/
      FENCE_LANG = /\A(?:erb|ruby)\z/i

      class << self
        def for(klass, path)
          return [] if path.nil? || !File.file?(path)

          (index_for(path)[klass.name] || []).map { |body| {erb: body} }
        end

        def reset!
          @cache = nil
        end

        private

        def cache
          @cache ||= {}
        end

        def index_for(path)
          cache[File.expand_path(path)] ||= build_index(path)
        end

        def build_index(path)
          index = {}
          fences_from(example_section(File.read(path))).each do |body|
            body.scan(CLASS_TOKEN).uniq.each do |class_name|
              (index[class_name] ||= []) << body
            end
          end
          index
        end

        def example_section(text)
          lines = text.each_line.to_a
          start_at = lines.index { |line| line.match?(EXAMPLE_HEADING) }
          return "" if start_at.nil?

          rest = lines[(start_at + 1)..]
          stop_at = rest.index { |line| line.match?(NEXT_H2) }
          (stop_at ? rest[0...stop_at] : rest).join
        end

        def fences_from(section)
          fences = []
          body_lines = nil
          info = nil

          section.each_line do |line|
            if body_lines.nil?
              opened = line.match(FENCE_OPEN)
              next if opened.nil?

              info = opened[1]
              body_lines = []
              next
            end

            if line.match?(FENCE_CLOSE)
              fences << body_lines.join.chomp if info.match?(FENCE_LANG)
              body_lines = nil
              info = nil
              next
            end

            body_lines << line
          end

          fences
        end
      end
    end
  end
end
