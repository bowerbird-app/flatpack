# frozen_string_literal: true

module FlatPack
  module Navbar
    module SidebarSection
      class Component < FlatPack::BaseComponent
        renders_many :items, lambda { |*args, **kwargs|
          params = {}
          args.each_slice(2) { |k, v| params[k] = v }
          params.merge!(kwargs)
          FlatPack::Navbar::SidebarItem::Component.new(**params)
        }

        def initialize(title: nil, collapsible: false, collapsed: false, **system_arguments, &block)
          @title = title
          @collapsible = collapsible
          @collapsed = collapsed
          @block = block

          super(**system_arguments)
        end

        def item(...)
          with_item(...)
        end

        def call
          content_tag(:div, class: "mt-2") do
            safe_join([
              render_title,
              content_tag(:ul, class: items_list_classes) do
                safe_join(items.map { |item| content_tag(:li, item) })
              end
            ].compact)
          end
        end

        private

        def render_title
          return unless @title

          if @collapsible
            content_tag(:button, **title_button_attributes) do
              safe_join([
                content_tag(:span, @title, class: "flex-1 text-left"),
                chevron_icon
              ])
            end
          else
            content_tag(:h3, @title, class: title_classes, data: {flat_pack__navbar_target: "sectionTitle"})
          end
        end

        def title_button_attributes
          {
            type: "button",
            class: "flex items-center gap-2 w-full px-3 py-2 mb-2 text-xs font-semibold uppercase tracking-wider text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)] transition-colors",
            data: {
              action: "click->flat-pack--sidebar#toggleSection",
              flat_pack__navbar_target: "sectionTitle"
            }
          }
        end

        def title_classes
          "px-3 py-2 mb-2 text-xs font-semibold uppercase tracking-wider text-[var(--surface-muted-content-color)]"
        end

        def chevron_icon
          content_tag(:svg, **chevron_attributes) do
            content_tag(:path, nil, d: "m6 9 6 6 6-6")
          end
        end

        def chevron_attributes
          {
            xmlns: "http://www.w3.org/2000/svg",
            width: "16",
            height: "16",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2",
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            class: chevron_classes
          }
        end

        def chevron_classes
          classes(
            "transition-transform duration-200",
            @collapsed ? "" : "rotate-180"
          )
        end

        def items_list_classes
          classes(
            "space-y-1",
            (@collapsible && @collapsed) ? "hidden" : ""
          )
        end
      end
    end
  end
end
