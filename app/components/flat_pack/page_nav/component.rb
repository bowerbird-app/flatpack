# frozen_string_literal: true

module FlatPack
  module PageNav
    class Component < FlatPack::BaseComponent
      REMOVED_KEYWORDS = %i[
        show_back
        right_slot
        back_href
        back_icon
        back_tooltip
        back_label
        back_style
        back_size
        anchor_href
        anchor_icon
        anchor_tooltip
        anchor_label
        anchor_style
        anchor_size
      ].freeze

      def initialize(round: false, style: :secondary, size: :md, **system_arguments)
        reject_removed!(system_arguments)
        super(**system_arguments)

        @round = round
        @style = style
        @size = size
        @items = []
        @history_back = false
        @fallback_url = nil
        validate_round!
      end

      def with_item(&block)
        raise ArgumentError, "Page nav item needs a block." unless block

        remember { capture_item(&block) }
      end

      def with_back(href: nil, icon: nil, tooltip: nil, fallback_url: nil, style: nil, size: nil)
        label = tooltip.presence || fp_t("page_nav.back")
        link = href.presence
        record_history(link, fallback_url)
        remember do
          icon_control(
            icon: icon.presence || "chevron-left",
            label: label,
            style: style,
            size: size,
            href: link,
            data: link.present? ? nil : {action: "click->flat-pack--page-nav#back"}
          )
        end
      end

      def with_close(href:, icon: nil, tooltip: nil, style: nil, size: nil)
        raise ArgumentError, "Page nav close needs an href." if href.blank?

        label = tooltip.presence || fp_t("page_nav.close")
        remember do
          icon_control(
            icon: icon.presence || "x-mark",
            label: label,
            style: style,
            size: size,
            href: href
          )
        end
      end

      def with_link(href:, icon:, tooltip:, style: nil, size: nil)
        raise ArgumentError, "Page nav link needs an href." if href.blank?
        raise ArgumentError, "Page nav link needs an icon." if icon.blank?
        raise ArgumentError, "Page nav link needs a tooltip." if tooltip.blank?

        remember do
          icon_control(icon: icon, label: tooltip, style: style, size: size, href: href)
        end
      end

      def with_action(**button_arguments, &block)
        arguments = button_arguments.merge(round: @round)
        remember do
          if block
            render(FlatPack::Button::Component.new(**arguments), &block)
          else
            render(FlatPack::Button::Component.new(**arguments))
          end
        end
      end

      def call
        content
        content_tag(:nav, **nav_attributes) do
          content_tag(:div, class: "flex items-center gap-2") do
            safe_join(@items.map(&:call))
          end
        end
      end

      private

      def remember(&block)
        @items << block
        nil
      end

      def record_history(link, fallback_url)
        return if link.present?

        @history_back = true
        @fallback_url = fallback_url.presence
      end

      def nav_attributes
        attributes = {
          class: "flat-pack-page-nav",
          aria: {label: fp_t("page_nav.label")}
        }
        attributes[:data] = history_nav_data if @history_back
        merge_attributes(**attributes)
      end

      def history_nav_data
        data = {controller: "flat-pack--page-nav"}
        data[:flat_pack__page_nav_fallback_url_value] = @fallback_url if @fallback_url.present?
        data
      end

      def icon_control(icon:, label:, style:, size:, href: nil, data: nil)
        button = render(FlatPack::Button::Component.new(**icon_button_arguments(
          icon: icon,
          label: label,
          style: style,
          size: size,
          href: href,
          data: data
        )))
        return button if label.blank?

        render(FlatPack::Tooltip::Component.new(text: label)) { button }
      end

      def icon_button_arguments(icon:, label:, style:, size:, href:, data:)
        arguments = {
          icon: icon,
          icon_only: true,
          style: style || @style,
          size: size || @size,
          round: @round,
          aria: {label: label}
        }
        arguments[:href] = href if href.present?
        arguments[:data] = data if data.present?
        arguments
      end

      def capture_item
        capture { yield }.to_s.html_safe
      end

      def validate_round!
        return if @round == true || @round == false

        raise ArgumentError, "Invalid round: #{@round.inspect}. Must be true or false."
      end

      def reject_removed!(arguments)
        removed = arguments.keys.grep(/\Asecondary_anchor/)
        removed |= arguments.keys & REMOVED_KEYWORDS
        return if removed.empty?

        raise ArgumentError, "unknown keyword: :#{removed.first}"
      end
    end
  end
end
