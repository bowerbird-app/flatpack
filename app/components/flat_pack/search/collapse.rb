# frozen_string_literal: true

module FlatPack
  module Search
    class Collapse
      GROWS = %i[start end].freeze

      def self.resolve(collapsible:, collapsed:, grow:, value:)
        validate_flag!(:collapsible, collapsible)
        validate_flag!(:collapsed, collapsed)
        grow_name = normalize_grow!(grow)
        return Off.new unless collapsible

        On.new(collapsed: collapsed && !occupied?(value), grow: grow_name)
      end

      def self.occupied?(value)
        value.present?
      end

      def self.validate_flag!(name, flag)
        return if flag == true || flag == false

        raise ArgumentError, "Invalid #{name}: #{flag.inspect}. Must be true or false."
      end

      def self.normalize_grow!(grow)
        name = grow.to_sym
        return name if GROWS.include?(name)

        raise ArgumentError, "Invalid grow: #{grow.inspect}. Must be one of: start, end."
      rescue NoMethodError
        raise ArgumentError, "Invalid grow: #{grow.inspect}. Must be one of: start, end."
      end

      class Off
        def active? = false
      end

      class On
        def initialize(collapsed:, grow:)
          @collapsed = collapsed
          @grow = grow
        end

        def active? = true

        def collapsed? = @collapsed

        attr_reader :grow
      end
    end
  end
end
