# frozen_string_literal: true

module FlatPack
  module Navbar
    class TopNavComponent < FlatPack::BaseComponent
      renders_one :logo
      renders_one :actions

      def initialize(**system_arguments)
        super(**system_arguments)
      end

      def call
        tag.header(**header_attributes) do
          tag.div(class: "flex items-center justify-between h-full px-4") do
            safe_join([
              render_logo,
              render_actions
            ])
          end
        end
      end

      private

      def header_attributes
        merge_attributes(
          class: [
            "fixed top-0 left-0 right-0 z-50",
            "h-16",
            "bg-[var(--color-background)]/80",
            "backdrop-blur-lg backdrop-saturate-150",
            "border-b border-[var(--color-border)]",
            "transition-colors duration-300"
          ],
          data: {
            flat_pack__navbar_target: "topNav"
          }
        )
      end

      def render_logo
        return tag.div(class: "flex-1") unless logo
        
        tag.div(class: "flex-1") do
          logo
        end
      end

      def render_actions
        return default_actions unless actions

        tag.div(class: "flex items-center gap-2") do
          actions
        end
      end

      def default_actions
        tag.div(class: "flex items-center gap-2") do
          safe_join([
            render(FlatPack::Navbar::DarkModeToggleComponent.new),
            hamburger_button
          ])
        end
      end

      def hamburger_button
        tag.button(
          type: "button",
          class: [
            "md:hidden",
            "p-2 rounded-md",
            "text-[var(--color-foreground)]",
            "hover:bg-[var(--color-muted)]",
            "transition-colors duration-200"
          ],
          data: {
            action: "click->flat-pack--navbar#toggleMobile"
          },
          aria: { label: "Toggle menu" }
        ) do
          hamburger_icon
        end
      end

      def hamburger_icon
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-6 h-6",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M4 6h16M4 12h16M4 18h16"
          )
        end
      end
    end
  end
end
