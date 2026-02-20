# frozen_string_literal: true

module FlatPack
  module Breadcrumb
    class Component < FlatPack::BaseComponent
      renders_many :items, FlatPack::Breadcrumb::Item::Component

      # Alias for shorter syntax
      def item(**kwargs, &block)
        with_item(**kwargs, &block)
      end

      SEPARATORS = {
        chevron: "›",
        slash: "/",
        arrow: "→",
        dot: "•",
        custom: nil
      }.freeze

      def initialize(
        separator: :chevron,
        separator_icon: nil,
        show_back: false,
        back_text: "Back",
        back_icon: "chevron-left",
        back_fallback_url: "/",
        show_home: false,
        home_url: "/",
        home_text: "Home",
        home_icon: "home",
        max_items: nil,
        items: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @separator = separator.to_sym
        @separator_icon = separator_icon
        @show_back = show_back
        @back_text = back_text
        @back_icon = back_icon
        @back_fallback_url = back_fallback_url
        @show_home = show_home
        @home_url = home_url
        @home_text = home_text
        @home_icon = home_icon
        @max_items = max_items

        validate_separator!

        # Support array of items for convenience
        items&.each do |item|
          item(**item)
        end
      end

      def call
        content_tag(:nav, **nav_attributes) do
          content_tag(:ol, class: breadcrumb_classes) do
            safe_join(render_items_with_separators)
          end
        end
      end

      private

      def render_items_with_separators
        all_items = build_items_list
        collapsed_items = maybe_collapse_items(all_items)

        collapsed_items.flat_map.with_index do |item, index|
          elements = [render_item(item, index)]

          # Add separator unless it's the last item
          unless index == collapsed_items.size - 1 || skip_separator_after_index?(index)
            elements << render_separator
          end

          elements
        end
      end

      def skip_separator_after_index?(index)
        @show_back && index.zero?
      end

      def build_items_list
        items_list = []

        # Add back item if requested
        if @show_back
          items_list << item(
            text: @back_text,
            href: back_href,
            icon: @back_icon
          )
        end

        # Add home item if requested
        if @show_home
          items_list << item(
            text: @home_text,
            href: @home_url,
            icon: @home_icon
          )
        end

        items_list + items
      end

      def back_href
        request&.referer || @back_fallback_url
      end

      def maybe_collapse_items(items_list)
        return items_list if @max_items.nil? || items_list.size <= @max_items

        # Keep first item, last (max_items - 1) items, and add ellipsis
        [
          items_list.first,
          build_ellipsis_item,
          *items_list.last(@max_items - 1)
        ]
      end

      def build_ellipsis_item
        FlatPack::Breadcrumb::Item::Component.new(
          text: "...",
          href: nil
        )
      end

      def render_item(item, index)
        content_tag(:li, class: "inline-flex items-center") do
          render(item)
        end
      end

      def render_separator
        content_tag(:li,
          class: "inline-flex items-center mx-2 text-[var(--color-muted-foreground)]",
          aria: {hidden: "true"}) do
          if @separator == :custom && @separator_icon
            render(FlatPack::Shared::IconComponent.new(
              name: @separator_icon,
              size: :sm
            ))
          else
            SEPARATORS.fetch(@separator)
          end
        end
      end

      def nav_attributes
        attrs = {
          class: wrapper_classes,
          aria: {label: "Breadcrumb"}
        }
        merge_attributes(**attrs)
      end

      def wrapper_classes
        classes("flat-pack-breadcrumb", @custom_class)
      end

      def breadcrumb_classes
        "flex items-center flex-wrap gap-1 text-sm"
      end

      def validate_separator!
        return if SEPARATORS.key?(@separator)

        raise ArgumentError,
          "Invalid separator: #{@separator}. Must be one of: #{SEPARATORS.keys.join(", ")}"
      end
    end
  end
end
