# frozen_string_literal: true

module FlatPack
  module Comments
    module Item
      class Component < FlatPack::BaseComponent
        renders_one :actions
        renders_one :footer
        renders_one :replies

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "bg-background" "border-border" "bg-zinc-50" "dark:bg-zinc-800/50" "text-muted-foreground"
        STATES = {
          default: "bg-background border-border",
          system: "bg-zinc-50 dark:bg-zinc-800/50 border-border",
          deleted: "bg-background border-border opacity-60"
        }.freeze

        def initialize(
          author_name:,
          author_meta: nil,
          timestamp: nil,
          timestamp_iso: nil,
          body: nil,
          body_html: nil,
          edited: false,
          state: :default,
          avatar: {},
          **system_arguments
        )
          super(**system_arguments)
          @author_name = author_name
          @author_meta = author_meta
          @timestamp = timestamp
          @timestamp_iso = timestamp_iso
          @body = body
          @body_html = body_html
          @edited = edited
          @state = state.to_sym
          @avatar = avatar.is_a?(Hash) ? avatar.symbolize_keys : {}

          validate_author!
          validate_state!
        end

        def call
          content_tag(:div, **item_attributes) do
            safe_join([
              render_avatar_column,
              render_content_column
            ])
          end
        end

        private

        def item_attributes
          merge_attributes(
            class: item_classes
          )
        end

        def item_classes
          classes(
            "flex gap-3"
          )
        end

        def render_avatar_column
          content_tag(:div, class: "shrink-0") do
            FlatPack::Avatar::Component.new(
              src: @avatar[:src],
              alt: @avatar[:alt] || @author_name,
              name: @avatar[:name] || @author_name,
              initials: @avatar[:initials],
              size: :sm,
              shape: :circle,
              href: @avatar[:href]
            ).render_in(view_context)
          end
        end

        def render_content_column
          content_tag(:div, class: "flex-1 min-w-0") do
            content_tag(:div, class: content_card_classes) do
              safe_join([
                render_header,
                render_body,
                render_footer_section,
                render_actions_section
              ].compact)
            end
          end
        end

        def content_card_classes
          classes(
            "rounded-lg border p-4 space-y-3",
            STATES.fetch(@state)
          )
        end

        def render_header
          content_tag(:div, class: "flex items-start justify-between gap-2") do
            safe_join([
              render_author_info,
              render_timestamp
            ].compact)
          end
        end

        def render_author_info
          content_tag(:div) do
            safe_join([
              content_tag(:div, class: "font-medium text-sm text-foreground") do
                safe_join([
                  content_tag(:span, @author_name),
                  @state == :system ? render_system_badge : nil
                ].compact)
              end,
              @author_meta ? content_tag(:div, @author_meta, class: "text-xs text-muted-foreground") : nil
            ].compact)
          end
        end

        def render_system_badge
          content_tag(:span,
            "System",
            class: "ml-2 inline-flex items-center px-2 py-0.5 rounded text-[10px] font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400"
          )
        end

        def render_timestamp
          return unless @timestamp

          time_attrs = {
            class: "text-xs text-muted-foreground whitespace-nowrap"
          }
          time_attrs[:datetime] = @timestamp_iso if @timestamp_iso

          content_tag(:time, **time_attrs) do
            safe_join([
              content_tag(:span, @timestamp),
              @edited ? render_edited_indicator : nil
            ].compact)
          end
        end

        def render_edited_indicator
          content_tag(:span, " (edited)", class: "italic")
        end

        def render_body
          return render_deleted_message if @state == :deleted

          if @body_html
            content_tag(:div, @body_html.html_safe, class: "text-sm text-foreground prose prose-sm max-w-none")
          elsif @body
            content_tag(:div, @body, class: "text-sm text-foreground whitespace-pre-wrap")
          end
        end

        def render_deleted_message
          content_tag(:div, class: "text-sm italic text-muted-foreground") do
            "This comment has been deleted."
          end
        end

        def render_footer_section
          return unless footer?

          content_tag(:div, footer, class: "pt-2 border-t border-border")
        end

        def render_actions_section
          return unless actions?
          return if @state == :deleted

          content_tag(:div, actions, class: "flex items-center gap-3 pt-2")
        end

        def validate_author!
          return if @author_name.present?
          raise ArgumentError, "author_name is required"
        end

        def validate_state!
          return if STATES.key?(@state)
          raise ArgumentError, "Invalid state: #{@state}. Must be one of: #{STATES.keys.join(", ")}"
        end
      end
    end
  end
end
