# frozen_string_literal: true

module FlatPack
  module Navbar
    class LeftNavComponent < FlatPack::BaseComponent
      renders_many :sections, FlatPack::Navbar::NavSectionComponent
      renders_many :items, FlatPack::Navbar::NavItemComponent

      def initialize(**system_arguments)
        super(**system_arguments)
      end

      def call
        tag.div(class: "flex h-full") do
          safe_join([
            render_nav,
            mobile_overlay
          ])
        end
      end

      private

      def render_nav
        tag.nav(**nav_attributes) do
          tag.div(class: "flex flex-col h-full") do
            safe_join([
              render_content,
              render_toggle_button
            ])
          end
        end
      end

      def nav_attributes
        merge_attributes(
          class: [
            # Desktop: Always visible, collapsible
            "hidden md:block",
            "w-64 transition-all duration-300",
            # Mobile: Overlay from right
            "md:relative fixed inset-y-0 right-0",
            "mt-16 md:mt-0",
            "bg-[var(--color-background)]",
            "border-r border-[var(--color-border)]",
            "z-40",
            "transform translate-x-full md:translate-x-0"
          ],
          data: {
            flat_pack__navbar_target: "leftNav",
            flat_pack__dark_mode_target: "nav"
          }
        )
      end

      def render_content
        tag.div(class: "flex-1 overflow-y-auto py-4") do
          if sections.any?
            safe_join(sections)
          elsif items.any?
            tag.div(class: "px-2 space-y-1") do
              safe_join(items)
            end
          end
        end
      end

      def render_toggle_button
        tag.div(class: "hidden md:flex p-4 border-t border-[var(--color-border)]") do
          tag.button(
            type: "button",
            class: [
              "w-full p-2 rounded-md",
              "text-[var(--color-foreground)]",
              "hover:bg-[var(--color-muted)]",
              "transition-colors duration-200",
              "flex items-center justify-center gap-2"
            ],
            data: {
              action: "click->flat-pack--navbar#toggleCollapse"
            },
            aria: { label: "Toggle sidebar" }
          ) do
            safe_join([
              chevron_icon,
              tag.span("Collapse", class: "text-sm", data: { flat_pack__navbar_target: "collapseText" })
            ])
          end
        end
      end

      def chevron_icon
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-5 h-5 transition-transform duration-200",
          data: { flat_pack__navbar_target: "collapseIcon" },
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M15 19l-7-7 7-7"
          )
        end
      end

      def mobile_overlay
        tag.div(
          class: [
            "md:hidden fixed inset-0 bg-black/50 z-30",
            "opacity-0 pointer-events-none",
            "transition-opacity duration-300"
          ],
          data: {
            flat_pack__navbar_target: "overlay",
            action: "click->flat-pack--navbar#closeMobile"
          }
        )
      end
    end
  end
end
