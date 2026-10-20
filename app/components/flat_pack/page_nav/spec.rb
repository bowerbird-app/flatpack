# frozen_string_literal: true

module FlatPack
  module PageNav
    class Spec
      DEPRECATED_LABELS = %i[back_label anchor_label].freeze
      HTML_ATTRIBUTES = %i[class id data aria].freeze

      def initialize(**kwargs, &block)
        rejected = kwargs.keys & DEPRECATED_LABELS
        if rejected.any?
          raise ArgumentError, "Unknown page nav argument: #{rejected.join(", ")}"
        end

        unknown = kwargs.keys - self.class.allowed_keys
        if unknown.any?
          raise ArgumentError, "Unknown page nav argument: #{unknown.join(", ")}"
        end

        @kwargs = kwargs.freeze
        @links = []
        block&.call(self)
      end

      def with_link(href:, icon:, tooltip:)
        @links << {href: href, icon: icon, tooltip: tooltip}
      end

      def links
        @links.dup
      end

      def with_inbound_anchor(url)
        return self if @kwargs[:anchor_href].present? || url.blank?

        duplicate = self.class.new(**@kwargs, anchor_href: url)
        @links.each { |link| duplicate.with_link(**link) }
        duplicate
      end

      def to_component_kwargs
        @kwargs.dup
      end

      def self.allowed_keys
        FlatPack::PageNav::Component.instance_method(:initialize).parameters.filter_map { |type, name|
          name if type == :key && !DEPRECATED_LABELS.include?(name)
        } + HTML_ATTRIBUTES
      end
    end
  end
end
