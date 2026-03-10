# frozen_string_literal: true

module FlatPack
  module Navbar
    class Component < FlatPack::BaseComponent
      renders_one :sidebar, lambda { |*args|
        kwargs = {}
        args.each_slice(2) { |k, v| kwargs[k] = v }
        FlatPack::Navbar::Sidebar::Component.new(**kwargs)
      }

      renders_one :top_nav, lambda { |*args|
        kwargs = {}
        args.each_slice(2) { |k, v| kwargs[k] = v }
        FlatPack::Navbar::TopNav::Component.new(**kwargs)
      }

      undef_method :with_sidebar, :with_sidebar_content,
        :with_top_nav, :with_top_nav_content

      def initialize(**system_arguments)
        super
      end

      def sidebar(*args, **kwargs, &block)
        return get_slot(:sidebar) if args.empty? && kwargs.empty? && !block_given? && sidebar?

        set_slot(:sidebar, nil, *args, **kwargs, &block)
      end

      def top_nav(*args, **kwargs, &block)
        return get_slot(:top_nav) if args.empty? && kwargs.empty? && !block_given? && top_nav?

        set_slot(:top_nav, nil, *args, **kwargs, &block)
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            sidebar,
            content_tag(:div, class: "flex flex-col flex-1") do
              safe_join([top_nav, content_tag(:main, content, class: main_classes)].compact)
            end
          ].compact)
        end
      end

      private

      def wrapper_attributes
        merge_attributes(
          class: wrapper_classes,
          data: {
            controller: "flat-pack--navbar",
            flat_pack__navbar_expanded_width_value: "256px",
            flat_pack__navbar_collapsed_width_value: "64px",
            flat_pack__navbar_collapsed_value: false
          }
        )
      end

      def wrapper_classes
        classes(
          "flex",
          "h-full",
          "bg-[var(--surface-background-color)]"
        )
      end

      def main_classes
        "flex-1 overflow-auto"
      end
    end
  end
end
