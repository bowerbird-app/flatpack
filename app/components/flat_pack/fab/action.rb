# frozen_string_literal: true

module FlatPack
  module Fab
    class Action < FlatPack::BaseComponent
      def initialize(icon:, label:, href: nil, **system_arguments)
        super(**system_arguments)
        @icon = icon
        @label = label.to_s
        @href = href ? FlatPack::AttributeSanitizer.sanitize_url(href) : nil

        validate_label!
        validate_href!(href) if href
      end

      def call
        content_tag(:li, role: "none", class: "fp-fab__action-item") do
          if @href
            link_to(@href, **item_attributes) { item_content }
          else
            button_tag(**item_attributes) { item_content }
          end
        end
      end

      private

      def item_content
        safe_join([
          content_tag(:span, @label, class: "fp-fab__action-label"),
          content_tag(:span, render_icon, class: "fp-fab__action-glyph justify-center", aria: {hidden: true})
        ])
      end

      def render_icon
        render FlatPack::Shared::IconComponent.new(name: @icon, size: :md)
      end

      def item_attributes
        attrs = {
          class: "fp-fab__action fp-hit-target fp-touch-manipulation",
          role: "menuitem",
          tabindex: "-1",
          aria: {label: @label}
        }
        attrs[:type] = "button" unless @href
        merged = merge_attributes(**attrs)
        merged[:data] = merge_data_attributes(merged[:data], item_data)
        merged
      end

      def item_data
        {
          flat_pack__fab_target: "action",
          action: "click->flat-pack--fab#choose"
        }
      end

      def validate_label!
        return if @label.present?

        raise ArgumentError, "FAB actions need a label."
      end

      def validate_href!(original_url)
        return if @href.present?

        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
