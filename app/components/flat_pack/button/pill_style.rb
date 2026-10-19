# frozen_string_literal: true

module FlatPack
  module Button
    class PillStyle
      DEFAULT = nil
      GROUP_CLASS = "fp-pill-style"
      BUTTON_SLOTS_CLASS = "fp-pill-button-slots"
      ACTIVE_CLASSES = "border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]"
      INACTIVE_CLASSES = "border-transparent text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]"
      ACTIVE_TEXT_CLASSES = "text-[var(--tabs-pill-active-text-color)]"
      INACTIVE_TEXT_CLASSES = "text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)]"

      def self.resolve(style)
        return new(nil) if style.nil?

        name = style.to_sym
        raise ArgumentError, StyleRegistry.invalid_style_message(name) unless StyleRegistry.known?(name)

        new(name)
      end

      attr_reader :name

      def group_class
        return GROUP_CLASS if name.nil?

        "#{GROUP_CLASS} #{BUTTON_SLOTS_CLASS}"
      end

      def data_fp_style
        name&.to_s
      end

      def initialize(name)
        @name = name
      end
      private_class_method :new
    end
  end
end
