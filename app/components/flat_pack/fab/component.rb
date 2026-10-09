# frozen_string_literal: true

module FlatPack
  module Fab
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fixed" "absolute" "inset-0" "flex" "items-center" "justify-center"
      # "rounded-full" "hidden" "pointer-events-none"

      renders_many :actions, "FlatPack::Fab::Action"

      POSITIONS = %i[bottom_right bottom_left top_right top_left].freeze
      LAYOUTS = %i[stack].freeze
      SIZES = %i[md lg].freeze
      OFFSET_PATTERN = /\A\d+(?:\.\d+)?(?:px|rem|em)\z/

      def initialize(
        icon: :plus,
        label: nil,
        href: nil,
        position: :bottom_right,
        size: :md,
        layout: :stack,
        backdrop: true,
        hide_on_scroll: false,
        contained: false,
        offset: nil,
        **system_arguments
      )
        super(**system_arguments)
        @icon = icon
        @label = label.presence
        @position = position.to_sym
        @size = size.to_sym
        @layout = layout.to_sym
        @backdrop = backdrop
        @hide_on_scroll = hide_on_scroll
        @contained = contained
        @offset = offset
        @href = href ? FlatPack::AttributeSanitizer.sanitize_url(href) : nil

        validate_position!
        validate_size!
        validate_layout!
        validate_offset!
        validate_href!(href) if href
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            (render_backdrop if speed_dial? && @backdrop),
            content_tag(:div, class: "fp-fab__cluster") do
              safe_join([
                (render_menu if speed_dial?),
                render_trigger
              ])
            end
          ])
        end
      end

      private

      def speed_dial?
        actions?
      end

      def root_attributes
        data = positioning_data
        data = merge_data_attributes(data, controller_data) if controller?

        if speed_dial?
          merged = merge_attributes(class: kit_root_classes, style: root_style)
          merged[:data] = merge_data_attributes(merged[:data], data)
          merged
        else
          {class: kit_root_classes, data: data, style: root_style}.compact
        end
      end

      def kit_root_classes
        ["fp-fab", (@contained ? "fp-fab--contained" : "fp-fab--viewport")].join(" ")
      end

      def positioning_data
        {
          fp_position: @position.to_s,
          fp_fab_layout: @layout.to_s,
          fp_size: @size.to_s
        }
      end

      def controller?
        speed_dial? || @hide_on_scroll
      end

      def controller_data
        {
          controller: "flat-pack--fab",
          action: controller_actions,
          flat_pack__fab_layout_value: @layout.to_s,
          flat_pack__fab_hide_on_scroll_value: @hide_on_scroll
        }
      end

      def controller_actions
        actions = ["resize@window->flat-pack--fab#onResize"]
        actions << "keydown.esc@window->flat-pack--fab#escape" if speed_dial?
        actions << "scroll@window->flat-pack--fab#onScroll" if @hide_on_scroll
        actions.join(" ")
      end

      def root_style
        return if @offset.blank?

        "--fp-fab-offset: #{@offset}"
      end

      def render_backdrop
        content_tag(
          :div,
          nil,
          class: "fp-fab__backdrop",
          data: {
            flat_pack__fab_target: "backdrop",
            action: "click->flat-pack--fab#close"
          },
          aria: {hidden: true}
        )
      end

      def render_menu
        content_tag(
          :ul,
          safe_join(actions),
          id: menu_id,
          class: "fp-fab__actions",
          role: "menu",
          hidden: true,
          data: {flat_pack__fab_target: "menu"},
          aria: {label: menu_label}
        )
      end

      def render_trigger
        if single_action_link?
          link_to(@href, **trigger_attributes) { trigger_content }
        else
          button_tag(**trigger_attributes) { trigger_content }
        end
      end

      def single_action_link?
        !speed_dial? && @href.present?
      end

      def trigger_content
        parts = [content_tag(:span, render_icon, class: "fp-fab__icon justify-center", aria: {hidden: true})]
        parts << content_tag(:span, @label, class: "fp-fab__text") if extended?
        safe_join(parts)
      end

      def render_icon
        render FlatPack::Shared::IconComponent.new(name: @icon, size: trigger_icon_size)
      end

      def trigger_icon_size
        (@size == :lg) ? :xl : :lg
      end

      def extended?
        @label.present? && !speed_dial?
      end

      def trigger_attributes
        attrs = {
          class: trigger_classes,
          aria: trigger_aria,
          data: trigger_data
        }
        attrs[:type] = "button" unless single_action_link?

        if speed_dial?
          trigger_only_attributes(**attrs)
        else
          merge_attributes(**attrs)
        end
      end

      def trigger_only_attributes(**attrs)
        {
          class: attrs.delete(:class),
          data: attrs.delete(:data) || {},
          aria: attrs.delete(:aria) || {}
        }.merge(attrs).compact
      end

      def trigger_classes
        [
          "fp-fab__trigger",
          "fp-hit-target",
          "fp-touch-manipulation",
          "justify-center",
          ("fp-fab__trigger--extended" if extended?)
        ].compact.join(" ")
      end

      def trigger_aria
        aria = {label: trigger_label}
        if speed_dial?
          aria[:expanded] = "false"
          aria[:controls] = menu_id
          aria[:haspopup] = "menu"
        end
        aria
      end

      def trigger_data
        data = {flat_pack__fab_target: "trigger"}
        data[:action] = "click->flat-pack--fab#toggle" if speed_dial?
        data
      end

      def trigger_label
        return @label if @label.present?
        return fp_t("fab.open_actions") if speed_dial?

        fp_t("fab.label")
      end

      def menu_label
        fp_t("fab.menu")
      end

      def menu_id
        @menu_id ||= begin
          given = html_attributes[:id].presence || html_attributes["id"].presence
          "#{given || "fp-fab-#{SecureRandom.hex(4)}"}-actions"
        end
      end

      def validate_position!
        return if POSITIONS.include?(@position)

        raise ArgumentError, "Invalid position: #{@position}. Must be one of: #{POSITIONS.join(", ")}"
      end

      def validate_size!
        return if SIZES.include?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.join(", ")}"
      end

      def validate_layout!
        return if LAYOUTS.include?(@layout)

        raise ArgumentError, "Invalid layout: #{@layout}. Must be one of: #{LAYOUTS.join(", ")}. An :arc layout is planned for a later release."
      end

      def validate_offset!
        return if @offset.nil?
        return if @offset.is_a?(String) && OFFSET_PATTERN.match?(@offset)

        raise ArgumentError, "Invalid offset: #{@offset.inspect}. Use a CSS length such as \"1rem\" or \"16px\"."
      end

      def validate_href!(original_url)
        return if @href.present?

        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
