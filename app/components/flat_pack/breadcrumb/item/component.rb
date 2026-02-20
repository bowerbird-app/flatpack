# frozen_string_literal: true

module FlatPack
  module Breadcrumb
    module Item
      class Component < ViewComponent::Base
        def initialize(
          text:,
          href: nil,
          icon: nil,
          **system_arguments
        )
          @text = text
          @href = href
          @icon = icon
          @system_arguments = system_arguments

          validate_text!
        end

        def current?
          @href.nil?
        end

        def call
          if current?
            render_current_item
          else
            render_link_item
          end
        end

        private

        def render_current_item
          content_tag(:span,
            class: "flex items-center text-[var(--color-foreground)] font-medium",
            aria: {current: "page"}) do
            item_content
          end
        end

        def render_link_item
          link_to(@href,
            {
              class: "flex items-center text-[var(--color-muted-foreground)] hover:text-[var(--color-foreground)] transition-colors"
            }.merge(@system_arguments)) do
            item_content
          end
        end

        def item_content
          if @icon
            safe_join([
              render(FlatPack::Shared::IconComponent.new(name: @icon, size: :sm)),
              content_tag(:span, @text, class: "ml-1")
            ])
          else
            @text
          end
        end

        def validate_text!
          raise ArgumentError, "text is required" if @text.nil? || @text.to_s.strip.empty?
        end
      end
    end
  end
end
