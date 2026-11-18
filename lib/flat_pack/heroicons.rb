# frozen_string_literal: true

require "json"

module FlatPack
  # Lazy in-memory copy of Heroicons 2.2.0 inner SVG markup.
  # Heroicons MIT. Regenerate with `npm run build:heroicons`.
  module Heroicons
    VARIANTS = %w[outline solid mini micro].freeze
    PATH = File.expand_path("heroicons/paths.json", __dir__)
    MUTEX = Mutex.new

    class << self
      def fetch(variant, name)
        banks[variant.to_s]&.[](name.to_s)
      end

      def banks
        return @banks if @banks

        MUTEX.synchronize do
          @banks ||= load_banks
        end
      end

      private

      def load_banks
        raw = File.read(PATH).sub(/\A\s*\/\/.*\n/, "")
        parsed = JSON.parse(raw)
        VARIANTS.to_h { |variant|
          bank = parsed.fetch(variant).each_with_object({}) { |(icon_name, markup), memo|
            memo[icon_name.freeze] = markup.freeze
          }
          [variant.freeze, bank.freeze]
        }.freeze
      end
    end
  end
end
