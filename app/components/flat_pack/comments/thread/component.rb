# frozen_string_literal: true

module FlatPack
  module Comments
    module Thread
      class Component < FlatPack::BaseComponent
        renders_one :header
        renders_one :composer
        renders_many :comments
        renders_one :footer

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "space-y-4" "space-y-2"
        VARIANTS = {
          default: "space-y-4",
          compact: "space-y-2"
        }.freeze

        def initialize(
          count: 0,
          title: "Comments",
          variant: :default,
          empty_title: "No comments yet",
          empty_body: "Be the first to share your thoughts.",
          locked: false,
          **system_arguments
        )
          super(**system_arguments)
          @count = count
          @title = title
          @variant = variant.to_sym
          @empty_title = empty_title
          @empty_body = empty_body
          @locked = locked

          validate_variant!
        end

        def call
          content_tag(:div, **thread_attributes) do
            safe_join([
              render_header_section,
              render_composer_section,
              render_comments_section,
              render_footer_section
            ].compact)
          end
        end

        private

        def thread_attributes
          merge_attributes(
            class: thread_classes
          )
        end

        def thread_classes
          classes(
            "space-y-6",
            VARIANTS.fetch(@variant)
          )
        end

        def render_header_section
          if header?
            header
          else
            render_default_header
          end
        end

        def render_default_header
          content_tag(:div, class: "flex items-center justify-between border-b border-[var(--surface-border-color)] pb-4") do
            safe_join([
              content_tag(:div, class: "flex items-center gap-2") do
                safe_join([
                  content_tag(:h3, @title, class: "text-lg font-semibold text-[var(--surface-content-color)]"),
                  content_tag(:span, @count.to_s, class: "text-sm text-[var(--surface-muted-content-color)]")
                ])
              end,
              @locked ? render_locked_indicator : nil
            ].compact)
          end
        end

        def render_locked_indicator
          content_tag(:div, class: "flex items-center gap-1.5 text-sm text-[var(--surface-muted-content-color)]") do
            safe_join([
              # Lock icon
              content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 20 20",
                fill: "currentColor",
                class: "h-4 w-4") do
                content_tag(:path,
                  nil,
                  "fill-rule": "evenodd",
                  d: "M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z",
                  "clip-rule": "evenodd"
                )
              end,
              content_tag(:span, "Locked")
            ])
          end
        end

        def render_composer_section
          return if @locked
          return unless composer?

          content_tag(:div, composer, class: "pt-2")
        end

        def render_comments_section
          comments? ? safe_join(comments) : render_empty_state
        end

        def render_empty_state
          content_tag(:div, class: "py-12 text-center") do
            safe_join([
              content_tag(:h4, @empty_title, class: "text-sm font-medium text-[var(--surface-content-color)] mb-1"),
              content_tag(:p, @empty_body, class: "text-sm text-[var(--surface-muted-content-color)]")
            ])
          end
        end

        def render_footer_section
          footer if footer?
        end

        def validate_variant!
          return if VARIANTS.key?(@variant)
          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
        end
      end
    end
  end
end
