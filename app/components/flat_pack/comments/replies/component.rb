# frozen_string_literal: true

module FlatPack
  module Comments
    module Replies
      class Component < FlatPack::BaseComponent
        renders_many :comments

        def initialize(
          depth: 1,
          collapsed: false,
          collapsed_label: "Show replies",
          **system_arguments
        )
          super(**system_arguments)
          @depth = depth
          @collapsed = collapsed
          @collapsed_label = collapsed_label
        end

        def call
          content_tag(:div, **replies_attributes) do
            if @collapsed
              render_collapsed_state
            else
              render_comments_list
            end
          end
        end

        private

        def replies_attributes
          merge_attributes(
            class: replies_classes
          )
        end

        def replies_classes
          # Indent based on depth
          indent_class = case @depth
          when 1 then "ml-11"
          when 2 then "ml-11"
          else "ml-11"
          end

          classes(
            indent_class,
            "border-l-2 border-border pl-4 space-y-4"
          )
        end

        def render_collapsed_state
          content_tag(:button,
            type: "button",
            class: "text-sm font-medium text-primary hover:text-primary/80 transition-colors duration-base") do
            safe_join([
              # Chevron right icon
              content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 20 20",
                fill: "currentColor",
                class: "inline h-4 w-4 mr-1") do
                content_tag(:path,
                  nil,
                  "fill-rule": "evenodd",
                  d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z",
                  "clip-rule": "evenodd"
                )
              end,
              content_tag(:span, @collapsed_label)
            ])
          end
        end

        def render_comments_list
          return unless comments?
          
          safe_join(comments)
        end
      end
    end
  end
end
