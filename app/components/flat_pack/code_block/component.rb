# frozen_string_literal: true

module FlatPack
  module CodeBlock
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--color-muted)]" "border" "border-[var(--color-border)]" "rounded-lg" "overflow-x-auto" "font-mono" "text-sm" "text-[var(--color-foreground)]" "text-[var(--color-muted-foreground)]"
      def initialize(code:, language: nil, title: nil, **system_arguments)
        super(**system_arguments)
        @code = code
        @language = language
        @title = title
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_title,
            render_code_block
          ].compact)
        end
      end

      private

      def render_title
        return unless @title.present?

        content_tag(:div, @title, class: "px-4 py-2 border-b border-[var(--color-border)] text-sm font-medium text-[var(--color-muted-foreground)]")
      end

      def render_code_block
        content_tag(:pre, class: pre_classes) do
          content_tag(:code, @code, class: code_classes)
        end
      end

      def wrapper_attributes
        merge_attributes(class: wrapper_classes)
      end

      def wrapper_classes
        classes(
          "bg-[var(--color-muted)]",
          "border border-[var(--color-border)]",
          "rounded-lg"
        )
      end

      def pre_classes
        @title.present? ? "p-4 overflow-x-auto" : "p-4 rounded-lg overflow-x-auto"
      end

      def code_classes
        base_classes = "font-mono text-sm text-[var(--color-foreground)]"
        return base_classes unless @language.present?

        "#{base_classes} language-#{@language}"
      end
    end
  end
end
