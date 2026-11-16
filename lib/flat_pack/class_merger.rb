# frozen_string_literal: true

require "tailwind_merge"

module FlatPack
  module ClassMerger
    class << self
      def merge(class_names)
        merger.merge(class_names)
      end

      def merger
        @merger ||= TailwindMerge::Merger.new
      end
    end
  end
end
