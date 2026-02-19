# frozen_string_literal: true

module FlatPack
  module Chat
    module Attachment
      class Component < FlatPack::BaseComponent
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "border" "border-[var(--color-border)]" "rounded-lg" "p-3" "hover:bg-[var(--color-muted)]"
        TYPES = {
          file: "file",
          image: "image"
        }.freeze

        def initialize(
          type: :file,
          name:,
          meta: nil,
          href: nil,
          thumbnail_url: nil,
          **system_arguments
        )
          super(**system_arguments)
          @type = type.to_sym
          @name = name
          @meta = meta
          @href = href
          @thumbnail_url = thumbnail_url

          validate_type!
          validate_name!
        end

        def call
          if @type == :image && @thumbnail_url.present?
            render_image_attachment
          else
            render_file_attachment
          end
        end

        private

        def render_image_attachment
          wrapper = if @href
            ->(content) { content_tag(:a, content, href: @href, target: "_blank", rel: "noopener noreferrer") }
          else
            ->(content) { content }
          end

          wrapper.call(
            content_tag(:div, class: image_container_classes) do
              content_tag(:img,
                nil,
                src: @thumbnail_url,
                alt: @name,
                loading: "lazy",
                class: "w-full h-full object-cover"
              )
            end
          )
        end

        def render_file_attachment
          content = content_tag(:div, class: file_container_classes) do
            safe_join([
              render_file_icon,
              content_tag(:div, class: "flex-1 min-w-0") do
                safe_join([
                  content_tag(:div, @name, class: "text-sm font-medium text-[var(--color-foreground)] truncate"),
                  (@meta ? content_tag(:div, @meta, class: "text-xs text-[var(--color-muted-foreground)]") : nil)
                ].compact)
              end,
              render_download_icon
            ])
          end

          if @href
            content_tag(:a, content, **file_link_attributes)
          else
            content
          end
        end

        def render_file_icon
          content_tag(:div, class: "flex-shrink-0") do
            # File icon
            content_tag(:svg,
              xmlns: "http://www.w3.org/2000/svg",
              viewBox: "0 0 20 20",
              fill: "currentColor",
              class: "h-8 w-8 text-[var(--color-muted-foreground)]") do
              content_tag(:path,
                nil,
                "fill-rule": "evenodd",
                d: "M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z",
                "clip-rule": "evenodd"
              )
            end
          end
        end

        def render_download_icon
          return unless @href

          content_tag(:div, class: "flex-shrink-0") do
            # Download icon
            content_tag(:svg,
              xmlns: "http://www.w3.org/2000/svg",
              viewBox: "0 0 20 20",
              fill: "currentColor",
              class: "h-5 w-5 text-[var(--color-muted-foreground)]") do
              safe_join([
                content_tag(:path,
                  nil,
                  "fill-rule": "evenodd",
                  d: "M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z",
                  "clip-rule": "evenodd"
                )
              ])
            end
          end
        end

        def file_link_attributes
          merge_attributes(
            href: @href,
            target: "_blank",
            rel: "noopener noreferrer",
            class: "block"
          )
        end

        def image_container_classes
          classes(
            "rounded-lg overflow-hidden",
            "max-w-sm w-full",
            "border border-[var(--color-border)]",
            @href ? "cursor-pointer hover:opacity-80 transition-opacity" : nil
          )
        end

        def file_container_classes
          classes(
            "flex items-center gap-3",
            "border border-[var(--color-border)]",
            "rounded-lg",
            "p-3",
            @href ? "hover:bg-[var(--color-muted)] transition-colors cursor-pointer" : nil
          )
        end

        def validate_type!
          return if TYPES.key?(@type)
          raise ArgumentError, "Invalid type: #{@type}. Must be one of: #{TYPES.keys.join(", ")}"
        end

        def validate_name!
          return if @name.present?
          raise ArgumentError, "name is required"
        end
      end
    end
  end
end
