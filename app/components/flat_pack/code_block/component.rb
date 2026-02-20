# frozen_string_literal: true

module FlatPack
  module CodeBlock
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--color-muted)]" "border" "border-[var(--color-border)]" "rounded-lg" "overflow-x-auto" "font-mono" "text-sm" "text-[var(--color-foreground)]" "text-[var(--color-muted-foreground)]"
      # "flex" "gap-1" "px-2" "pt-2" "pb-1" "rounded-full" "text-[var(--color-muted-foreground)]" "text-[var(--color-border-hover)]" "bg-[var(--color-border)]"
      def initialize(code: nil, language: nil, title: nil, snippets: nil, separated: true, **system_arguments)
        super(**system_arguments)
        @snippets = normalize_snippets(code: code, language: language, snippets: snippets)
        @title = title
        @separated = separated
        @default_tab = 0
        @component_id = "code-block-#{object_id}"
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
        return render_tabbed_code_block if multiple_snippets?

        content_tag(:pre, class: pre_classes) do
          content_tag(:code, @snippets.first[:code], class: code_classes_for(@snippets.first[:language]))
        end
      end

      def render_tabbed_code_block
        content_tag(:div, **tabbed_container_attributes) do
          safe_join([
            render_tab_list,
            render_tab_panels
          ])
        end
      end

      def render_tab_list
        content_tag(:div, class: tab_list_wrapper_classes) do
          content_tag(:div, role: "tablist", aria: {label: "Code snippets"}, class: tab_list_classes) do
            safe_join(@snippets.map.with_index { |snippet, index| render_tab_button(snippet, index) })
          end
        end
      end

      def render_tab_button(snippet, index)
        is_default = index == @default_tab

        content_tag(:button,
          snippet[:label],
          type: "button",
          role: "tab",
          id: tab_id(index),
          class: tab_classes(is_default),
          aria: {
            selected: is_default,
            controls: panel_id(index)
          },
          data: {
            "flat-pack--code-block-tabs-target": "tab",
            action: "click->flat-pack--code-block-tabs#selectTab keydown->flat-pack--code-block-tabs#handleKeydown"
          },
          tabindex: is_default ? 0 : -1)
      end

      def render_tab_panels
        safe_join(@snippets.map.with_index { |snippet, index| render_tab_panel(snippet, index) })
      end

      def render_tab_panel(snippet, index)
        is_default = index == @default_tab

        content_tag(:div,
          id: panel_id(index),
          role: "tabpanel",
          aria: {labelledby: tab_id(index)},
          data: {"flat-pack--code-block-tabs-target": "panel"},
          hidden: !is_default) do
          content_tag(:pre, class: pre_classes) do
            content_tag(:code, snippet[:code], class: code_classes_for(snippet[:language]))
          end
        end
      end

      def wrapper_attributes
        merge_attributes(class: wrapper_classes)
      end

      def tabbed_container_attributes
        {
          data: {
            controller: "flat-pack--code-block-tabs",
            "flat-pack--code-block-tabs-default-value": @default_tab
          }
        }
      end

      def wrapper_classes
        classes(
          (@separated ? "mt-4" : nil),
          "bg-[var(--color-muted)]",
          "border border-[var(--color-border)]",
          "rounded-lg"
        )
      end

      def pre_classes
        return "p-4 overflow-x-auto" if @title.present? || multiple_snippets?

        "p-4 rounded-lg overflow-x-auto"
      end

      def code_classes_for(language)
        base_classes = "font-mono text-sm text-[var(--color-foreground)]"
        return base_classes unless language.present?

        "#{base_classes} language-#{language}"
      end

      def tab_list_wrapper_classes
        "px-2 pt-2 pb-1"
      end

      def tab_list_classes
        "flex gap-1"
      end

      def tab_classes(is_active)
        base = "px-3 py-1.5 text-sm font-medium rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2"

        if is_active
          "#{base} bg-[var(--color-border)] text-[var(--color-muted-foreground)]"
        else
          "#{base} text-[var(--color-border-hover)]"
        end
      end

      def tab_id(index)
        "#{@component_id}-tab-#{index}"
      end

      def panel_id(index)
        "#{@component_id}-panel-#{index}"
      end

      def multiple_snippets?
        @snippets.length > 1
      end

      def normalize_snippets(code:, language:, snippets:)
        if snippets.present?
          normalized = snippets.filter_map do |snippet|
            snippet_hash = snippet.to_h
            next if snippet_hash[:code].nil? && snippet_hash["code"].nil?

            snippet_code = snippet_hash[:code] || snippet_hash["code"]
            snippet_label = snippet_hash[:label] || snippet_hash["label"]
            snippet_language = snippet_hash[:language] || snippet_hash["language"]

            {
              code: snippet_code.to_s,
              label: snippet_label.presence || snippet_fallback_label(snippet_language),
              language: snippet_language
            }
          end

          return normalized if normalized.any?
        end

        return [{code: code.to_s, label: snippet_fallback_label(language), language: language}] if code.present?

        raise ArgumentError, "CodeBlock::Component requires `code:` or non-empty `snippets:`"
      end

      def snippet_fallback_label(language)
        return "Snippet" if language.blank?

        language.to_s.upcase
      end
    end
  end
end
