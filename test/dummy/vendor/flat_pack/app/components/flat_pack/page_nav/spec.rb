# frozen_string_literal: true

module FlatPack
  module PageNav
    class Spec
      Item = Struct.new(:kind, :options, :html, keyword_init: true)

      COMPONENT_KEYS = %i[round style size class id data aria].freeze
      ARRANGEMENT_KEYS = %i[
        back_href
        back_icon
        back_tooltip
        back_style
        back_size
        anchor_href
        anchor_icon
        anchor_tooltip
        anchor_style
        anchor_size
      ].freeze
      REMOVED_KEYWORDS = %i[show_back right_slot back_label anchor_label].freeze

      def initialize(**kwargs, &block)
        reject_removed!(kwargs)
        unknown = kwargs.keys - COMPONENT_KEYS - ARRANGEMENT_KEYS
        if unknown.any?
          raise ArgumentError, "Unknown page nav argument: #{unknown.join(", ")}"
        end

        @component = kwargs.slice(*COMPONENT_KEYS).freeze
        @arrangement = kwargs.slice(*ARRANGEMENT_KEYS).freeze
        @items = []
        @custom = false
        return unless block

        @custom = true
        block.call(self)
      end

      def with_back(href: nil, icon: nil, tooltip: nil, fallback_url: nil, style: nil, size: nil)
        @items << Item.new(kind: :back, options: present_options(
          href: href,
          icon: icon,
          tooltip: tooltip,
          fallback_url: fallback_url,
          style: style,
          size: size
        ))
      end

      def with_close(href:, icon: nil, tooltip: nil, style: nil, size: nil)
        @items << Item.new(kind: :close, options: present_options(
          href: href,
          icon: icon,
          tooltip: tooltip,
          style: style,
          size: size
        ))
      end

      def with_link(href:, icon:, tooltip:, style: nil, size: nil)
        @items << Item.new(kind: :link, options: present_options(
          href: href,
          icon: icon,
          tooltip: tooltip,
          style: style,
          size: size
        ))
      end

      def with_action(**options, &block)
        @items << Item.new(kind: :action, options: options, html: block&.call)
      end

      def with_item
        raise ArgumentError, "Page nav item needs a block." unless block_given?

        @items << Item.new(kind: :html, html: yield)
      end

      def items
        (@custom ? @items : default_items).map(&:dup)
      end

      def anchor_href
        @arrangement[:anchor_href]
      end

      def to_component_kwargs
        @component.dup
      end

      def with_inbound_anchor(url)
        return self if @arrangement[:anchor_href].present? || url.blank?

        duplicate = self.class.new(**@component, **@arrangement, anchor_href: url)
        duplicate.send(:install_custom, @items) if @custom
        duplicate
      end

      private

      def install_custom(items)
        @custom = true
        @items = items.map(&:dup)
      end

      def default_items
        anchor = @arrangement[:anchor_href]
        rows = [Item.new(kind: :back, options: present_options(
          href: @arrangement[:back_href],
          icon: @arrangement[:back_icon],
          tooltip: @arrangement[:back_tooltip],
          fallback_url: anchor,
          style: @arrangement[:back_style],
          size: @arrangement[:back_size]
        ))]
        return rows if anchor.blank?

        rows << Item.new(kind: :close, options: present_options(
          href: anchor,
          icon: @arrangement[:anchor_icon],
          tooltip: @arrangement[:anchor_tooltip],
          style: @arrangement[:anchor_style],
          size: @arrangement[:anchor_size]
        ))
      end

      def present_options(**options)
        options.compact
      end

      def reject_removed!(kwargs)
        removed = kwargs.keys.grep(/\Asecondary_anchor/)
        removed |= kwargs.keys & REMOVED_KEYWORDS
        return if removed.empty?

        raise ArgumentError, "unknown keyword: :#{removed.first}"
      end
    end
  end
end
