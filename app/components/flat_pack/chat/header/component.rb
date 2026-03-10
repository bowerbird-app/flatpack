# frozen_string_literal: true

module FlatPack
  module Chat
    module Header
      class Component < FlatPack::BaseComponent
        AVATAR_MODES = {
          auto: :auto,
          person: :person,
          group: :group
        }.freeze

        renders_one :left_meta
        renders_one :right_slot

        undef_method :with_left_meta, :with_left_meta_content,
          :with_right_slot, :with_right_slot_content

        def initialize(
          title:,
          subtitle: nil,
          back_href: nil,
          back_label: "Back",
          content_url: nil,
          avatar_mode: :auto,
          person_avatar: nil,
          group_avatars: nil,
          group_max: 5,
          group_size: :sm,
          **system_arguments
        )
          super(**system_arguments)
          @title = title
          @subtitle = subtitle
          @back_href = back_href
          @back_label = back_label
          @content_url = sanitize_url(content_url)
          @avatar_mode = avatar_mode.to_sym
          @person_avatar = normalize_hash(person_avatar)
          @group_avatars = group_avatars || []
          @group_max = group_max
          @group_size = group_size

          validate_avatar_mode!
          validate_group_avatars!
          validate_content_url!(content_url)
        end

        def call
          content_tag(:div, **header_attributes) do
            safe_join([
              render_left_section,
              render_right_section
            ].compact)
          end
        end

        def left_meta(**args, &block)
          return get_slot(:left_meta) unless block

          set_slot(:left_meta, nil, **args, &block)
        end

        def right(**args, &block)
          return right_slot unless block

          set_slot(:right_slot, nil, **args, &block)
        end

        def right?
          right_slot?
        end

        private

        def render_left_section
          content_tag(:div, class: "flex min-w-0 flex-1 items-center gap-3") do
            safe_join([
              render_back_button,
              render_content_section
            ].compact)
          end
        end

        def render_content_section
          content = safe_join([
            render_avatar,
            render_text_content
          ].compact)

          if @content_url.present?
            link_to @content_url, class: content_link_classes do
              content
            end
          else
            content_tag(:div, class: content_container_classes) do
              content
            end
          end
        end

        def render_right_section
          return unless right?

          content_tag(:div, class: "flex items-center gap-2") do
            right.to_s
          end
        end

        def render_back_button
          return unless @back_href.present?

          render FlatPack::Button::Component.new(
            text: @back_label,
            icon: "chevron-left",
            style: :ghost,
            size: :sm,
            url: @back_href
          )
        end

        def render_avatar
          return render_group_avatar if group_avatar?
          return render_person_avatar if person_avatar?

          nil
        end

        def render_group_avatar
          render FlatPack::AvatarGroup::Component.new(
            items: @group_avatars,
            max: @group_max,
            size: @group_size
          )
        end

        def render_person_avatar
          render FlatPack::Avatar::Component.new(**@person_avatar)
        end

        def render_text_content
          content_tag(:div, class: "min-w-0") do
            safe_join([
              content_tag(:h2, @title, class: title_classes),
              render_subtitle,
              render_left_meta
            ].compact)
          end
        end

        def render_subtitle
          return unless @subtitle.present?

          content_tag(:p, @subtitle, class: subtitle_classes)
        end

        def render_left_meta
          return unless left_meta?

          content_tag(:div, class: "text-xs text-(--surface-muted-content-color)") do
            left_meta.to_s
          end
        end

        def group_avatar?
          return true if @avatar_mode == :group

          @avatar_mode == :auto && @group_avatars.any?
        end

        def person_avatar?
          return true if @avatar_mode == :person

          @avatar_mode == :auto && @person_avatar.present?
        end

        def title_classes
          classes(
            "truncate text-base font-semibold text-(--surface-content-color)"
          )
        end

        def subtitle_classes
          classes(
            "truncate text-sm text-(--surface-muted-content-color)"
          )
        end

        def header_attributes
          merge_attributes(
            class: header_classes
          )
        end

        def header_classes
          classes(
            "flex items-center justify-between gap-3 p-4"
          )
        end

        def content_container_classes
          classes(
            "flex min-w-0 flex-1 items-center gap-3"
          )
        end

        def content_link_classes
          classes(
            "flex min-w-0 flex-1 items-center gap-3 rounded-[var(--radius-md)]",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2"
          )
        end

        def normalize_hash(value)
          return {} unless value.is_a?(Hash)

          value.symbolize_keys
        end

        def validate_avatar_mode!
          return if AVATAR_MODES.key?(@avatar_mode)

          raise ArgumentError, "Invalid avatar_mode: #{@avatar_mode}. Must be one of: #{AVATAR_MODES.keys.join(", ")}"
        end

        def validate_group_avatars!
          return if @group_avatars.is_a?(Array)

          raise ArgumentError, "group_avatars must be an Array"
        end

        def sanitize_url(url)
          return nil if url.nil?

          FlatPack::AttributeSanitizer.sanitize_url(url)
        end

        def validate_content_url!(original_url)
          return unless original_url.present?
          return if @content_url.present?

          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
      end
    end
  end
end
