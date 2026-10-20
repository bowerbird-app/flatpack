# frozen_string_literal: true

module FlatPack
  module SidebarLayout
    # One edge column. The layout is the only public shell. Storage key
    # strings live here so the controller and the inline scripts cannot
    # invent a second suffix.
    class Panel
      attr_reader :role, :edge, :open, :resizable, :width_mode, :collapses,
        :floating, :content_height, :storage_key

      def self.rail(edge:, open:, resizable:, width_mode:, floating:, content_height:, storage_key:)
        new(
          role: :rail,
          edge: edge,
          open: open,
          resizable: resizable,
          width_mode: width_mode,
          collapses: true,
          floating: floating,
          content_height: content_height,
          storage_key: storage_key
        )
      end

      def self.aside(edge:, open:, resizable:, floating:, content_height:, storage_key:)
        new(
          role: :aside,
          edge: edge,
          open: open,
          resizable: resizable,
          width_mode: :fixed,
          collapses: false,
          floating: floating,
          content_height: content_height,
          storage_key: storage_key
        )
      end

      def initialize(role:, edge:, open:, resizable:, width_mode:, collapses:, floating:, content_height:, storage_key:)
        @role = role
        @edge = edge
        @open = open
        @resizable = resizable
        @width_mode = width_mode
        @collapses = collapses
        @floating = floating
        @content_height = content_height
        @storage_key = storage_key
      end

      def width_storage_key
        return if storage_key.blank?

        "#{storage_key}:#{role}:width"
      end

      def open_storage_key
        return if role != :aside || storage_key.blank?

        "#{storage_key}:aside"
      end

      def column_classes
        [
          "h-full",
          "md:h-screen",
          "md:self-start",
          "min-h-0",
          "transition-transform",
          "md:transition-[width,transform]",
          "duration-[var(--duration-slow)]",
          "ease-[var(--easing-standard)]",
          "transform-gpu",
          "will-change-transform",
          "block",
          "md:relative",
          "fixed",
          "inset-y-0",
          "md:w-auto",
          "z-50",
          "md:z-auto",
          "fp-sidebar-drawer",
          ((edge == :left) ? "left-0" : "right-0"),
          ((edge == :left) ? "-translate-x-full" : "translate-x-full"),
          "md:translate-x-0"
        ]
      end

      def column_data
        data = if role == :rail
          {
            "flat-pack--sidebar-layout-target": "sidebar",
            "mobile-drawer-side": edge.to_s,
            "flat-pack-sidebar-floating": ("true" if floating),
            "flat-pack-sidebar-height": ("content" if content_height),
            "flat-pack-sidebar-width": ("content" if width_mode == :content)
          }
        else
          {
            "flat-pack--sidebar-layout-target": "aside",
            "mobile-drawer-side": edge.to_s,
            "flat-pack-panel": "aside",
            "flat-pack-aside-open": open ? "true" : "false",
            "flat-pack-sidebar-floating": ("true" if floating),
            "flat-pack-sidebar-height": ("content" if content_height)
          }
        end

        data.merge(resize_controller_data || {}).compact
      end

      def resize_controller_data
        return unless resizable

        {
          "controller" => "flat-pack--panel-resize",
          "flat-pack--panel-resize-collapses-value" => collapses,
          "flat-pack--panel-resize-storage-key-value" => width_storage_key
        }.compact
      end

      def resize_label
        (role == :aside) ? "Resize aside" : "Resize sidebar"
      end
    end
  end
end
