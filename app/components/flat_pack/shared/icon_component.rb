# frozen_string_literal: true

module FlatPack
  module Shared
    class IconComponent < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "w-4" "h-4" "w-5" "h-5" "w-6" "h-6" "w-8" "h-8"
      SIZES = {
        sm: "w-4 h-4",
        md: "w-5 h-5",
        lg: "w-6 h-6",
        xl: "w-8 h-8"
      }.freeze

      # Maps legacy/shorthand names to canonical Heroicons v2 names.
      # Keys use dash-separated strings (underscores are converted before lookup).
      NAME_MAP = {
        "search"         => "magnifying-glass",
        "settings"       => "cog-6-tooth",
        "cog"            => "cog-6-tooth",
        "alert"          => "exclamation-triangle",
        "alert-triangle" => "exclamation-triangle",
        "alert-circle"   => "exclamation-circle",
        "info"           => "information-circle",
        "check-circle"   => "check-circle",
        "upload"         => "arrow-up-tray",
        "send"           => "paper-airplane",
        "box"            => "cube",
        "monitor"        => "computer-desktop",
        "laptop"         => "computer-desktop",
        "dashboard"      => "squares-2x2",
        "mail"           => "envelope",
        "edit-3"         => "pencil",
        "table"          => "table-cells",
        "type"           => "document-text",
        "square"         => "rectangle-stack",
        "menu"           => "bars-3",
        "calendar"       => "calendar-days",
        "file"           => "document",
        "image"          => "photo",
        "message-circle" => "chat-bubble-left-ellipsis",
        "dots"           => "ellipsis-vertical",
        "question"       => "question-mark-circle",
        "lock"           => "lock-closed",
        "align-left"     => "bars-3-bottom-left",
        "align-center"   => "bars-3",
        "align-right"    => "bars-3-bottom-right",
        "github"         => "code-bracket-square",
        "keyboard"       => "rectangle-group"
      }.freeze

      def initialize(name:, size: :md, variant: :outline, **system_arguments)
        super(**system_arguments)
        @name = name
        @size = size.to_sym
        @variant = variant.to_sym

        validate_size!
      end

      def call
        # Render an SVG shell; the icon_controller Stimulus controller fills in
        # the paths from the flat_pack/heroicons.js module (importmap-pinned).
        tag.svg(**svg_attributes)
      end

      private

      def svg_attributes
        merge_attributes(
          class: icon_classes,
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "1.5",
          aria: {hidden: "true"},
          data: {
            controller: "flat-pack--icon",
            "flat-pack--icon-name-value": heroicon_name,
            "flat-pack--icon-variant-value": @variant.to_s
          }
        )
      end

      def icon_classes
        classes("inline-block", size_classes)
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def heroicon_name
        raw = @name.to_s.tr("_", "-")
        NAME_MAP.fetch(raw, raw)
      end
    end
  end
end
