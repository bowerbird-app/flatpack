# frozen_string_literal: true

module FlatPack
  module Comments
    module Item
      class Component < FlatPack::BaseComponent
        renders_one :actions
        renders_one :footer
        renders_one :replies

        undef_method :with_actions, :with_actions_content,
          :with_footer, :with_footer_content,
          :with_replies, :with_replies_content

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "bg-[var(--comments-item-background-color)]" "bg-[var(--comments-item-system-background-color)]" "text-[var(--comments-item-meta-color)]" "rounded-[32px]" "shadow-sm"
        STATES = {
          default: nil,
          system: "rounded-[32px] bg-[var(--comments-item-system-background-color)] p-5 shadow-sm",
          deleted: "opacity-60"
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
            ].compact)
          end
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        def footer(*args, **kwargs, &block)
          return get_slot(:footer) if args.empty? && kwargs.empty? && !block

          set_slot(:footer, nil, *args, **kwargs, &block)
        end

        def replies(*args, **kwargs, &block)
          return get_slot(:replies) if args.empty? && kwargs.empty? && !block

          set_slot(:replies, nil, *args, **kwargs, &block)
        end

        private

        def item_attributes
          merge_attributes(
            class: item_classes
          )
        end

        def item_classes
          classes(
            "group flex w-full gap-4"
          )
        end

        def render_avatar_column
          content_tag(:div, class: "shrink-0") do
            FlatPack::Avatar::Component.new(
              src: @avatar[:src],
              alt: @avatar[:alt] || @author_name,
              name: @avatar[:name] || @author_name,
              initials: @avatar[:initials],
              size: :md,
              shape: :circle,
              href: @avatar[:href]
            ).render_in(view_context)
          end
        end

        def render_content_column
          content_tag(:div, class: content_column_classes) do
            safe_join([
              render_header,
              render_body,
              render_actions_section,
              render_footer_section,
              render_replies_section
            ].compact)
          end
        end

        def content_column_classes
          classes(
            "min-w-0 flex-1 space-y-3",
            STATES.fetch(@state)
          )
        end

        def render_header
          content_tag(:div, class: "flex items-start justify-between gap-4") do
            render_author_info
          end
        end

        def render_author_info
          content_tag(:div, class: "min-w-0") do
            safe_join([
              content_tag(:div, class: "flex flex-wrap items-center gap-x-2 gap-y-1") do
                safe_join([
                  content_tag(:div, class: "text-lg font-bold text-[var(--comments-item-author-color)]") do
                    safe_join([
                      content_tag(:span, @author_name),
                      (@state == :system) ? render_system_badge : nil
                    ].compact)
                  end,
                  render_timestamp
                ].compact)
              end,
              @author_meta ? content_tag(:div, @author_meta, class: "text-sm text-[var(--comments-item-meta-color)]") : nil
            ].compact)
          end
        end

        def render_system_badge
          content_tag(:span,
            "System",
            class: "ml-2 inline-flex items-center rounded-full border border-[var(--badge-info-border-color)] bg-[var(--badge-info-background-color)] px-2 py-0.5 text-[10px] font-medium text-[var(--badge-info-text-color)]")
        end

        def render_timestamp
          return unless @timestamp

          time_attrs = {
            class: "text-sm text-[var(--comments-item-meta-color)] whitespace-nowrap"
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
            content_tag(:div, @body_html.html_safe, class: "prose prose-sm mt-2 max-w-none text-[var(--comments-item-body-color)]")
          elsif @body
            content_tag(:div, @body, class: "mt-2 whitespace-pre-wrap text-sm leading-relaxed text-[var(--comments-item-body-color)]")
          end
        end

        def render_deleted_message
          content_tag(:div, class: "text-sm italic text-[var(--comments-item-deleted-text-color)]") do
            "This comment has been deleted."
          end
        end

        def render_footer_section
          return unless footer?

          content_tag(:div, footer, class: "mt-4 flex flex-wrap items-center gap-6")
        end

        def render_actions_section
          return unless actions?
          return if @state == :deleted

          content_tag(:div, actions, class: "mt-2")
        end

        def render_replies_section
          return unless replies?

          content_tag(:div, replies, class: "mt-4")
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
